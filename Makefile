# =============================================================================
# Integrated Micro Firewall – BSP & Build Makefile
# =============================================================================
# Usage:
#   make help            – Show available targets
#   make bsp-fetch       – Download BSP tarballs from GHCR
#   make bsp-extract     – Extract Yocto BSP layers
#   make bsp-push        – Push BSP tarballs to GHCR
#   make bsp-login       – Authenticate oras with GHCR
#   make bsp-status      – Show BSP file and layer status
#   make yocto-init      – Source the Yocto build environment
#   make yocto-build     – Run a Yocto build (myir-image-core)
#   make yocto-check     – Validate layer configuration
#   make clean-bsp       – Remove extracted BSP layers
#
# Overridable variables:
#   MACHINE=myd-yf13x          (default)
#   MACHINE=myd-yf13x-emmc     (eMMC variant)
#   MACHINE=myd-yf13x-nand     (NAND variant)
#   IMAGE=myir-image-core      (default)
# =============================================================================

SHELL        := /bin/bash
.DEFAULT_GOAL := help

# --- Paths -------------------------------------------------------------------
REPO_ROOT    := $(shell cd "$(dir $(lastword $(MAKEFILE_LIST)))" && pwd)
SCRIPTS_DIR  := $(REPO_ROOT)/scripts
STAGING_DIR  := $(REPO_ROOT)/.release-staging
BSP_DIR      := $(REPO_ROOT)/software/vendor/bsp
YOCTO_DIR    := $(REPO_ROOT)/yocto-bsp
LAYERS_DIR   := $(YOCTO_DIR)/layers
BUILD_DIR    := $(YOCTO_DIR)/build
OE_INIT      := $(LAYERS_DIR)/openembedded-core/oe-init-build-env
META_IMF     := $(REPO_ROOT)/software/meta-imf

# --- BSP tarball (the one that contains Yocto layers) ------------------------
BSP_TARBALL  := yf13x-yocto-stm32mp1-5.15.67.tar.bz2
BSP_TARBALL_PATH := $(STAGING_DIR)/$(BSP_TARBALL)

# --- Yocto settings ----------------------------------------------------------
# MACHINE: myd-yf13x | myd-yf13x-emmc | myd-yf13x-nand
MACHINE      ?= myd-yf13x
IMAGE        ?= myir-image-core
# TMPDIR name depends on DISTRO; nodistro uses tmp-glibc
YOCTO_TMPDIR ?= tmp-glibc

# --- Parallel build settings -------------------------------------------------
# Adjust to your host capabilities; 0 = auto-detect
BB_NUMBER_THREADS ?= 0
PARALLEL_MAKE     ?= 0

# --- OCI / GHCR settings -----------------------------------------------------
REPO_OWNER   := the78mole
REPO_NAME    := integrated-micro-firewall
REGISTRY     := ghcr.io/$(REPO_OWNER)/$(REPO_NAME)/vendor-bsp
OCI_TAG      := 1.0

# =============================================================================
#  Sentinel files for make dependencies
# =============================================================================
LAYERS_SENTINEL := $(LAYERS_DIR)/openembedded-core/oe-init-build-env

# =============================================================================
#  Targets
# =============================================================================

.PHONY: help
help: ## Show this help
	@echo ""
	@echo "Integrated Micro Firewall – BSP & Build Targets"
	@echo "================================================"
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'
	@echo ""

# ---------------------------------------------------------------------------
#  BSP download / upload
# ---------------------------------------------------------------------------

.PHONY: bsp-login
bsp-login: ## Authenticate oras CLI with GHCR (needs gh auth)
	@echo "==> Logging in to ghcr.io via oras …"
	@gh auth token | oras login ghcr.io -u $(REPO_OWNER) --password-stdin
	@echo "    ✓ Login successful"

.PHONY: bsp-fetch
bsp-fetch: ## Download BSP tarballs from GHCR → .release-staging/
	@echo "==> Fetching vendor BSP from GHCR …"
	$(SCRIPTS_DIR)/fetch-vendor-bsp.sh

.PHONY: bsp-push
bsp-push: ## Push BSP tarballs from .release-staging/ → GHCR
	@echo "==> Pushing vendor BSP to GHCR …"
	$(SCRIPTS_DIR)/push-vendor-bsp-oci.sh

# ---------------------------------------------------------------------------
#  BSP extraction
# ---------------------------------------------------------------------------

.PHONY: bsp-extract
bsp-extract: $(LAYERS_SENTINEL) ## Extract Yocto BSP layers from tarball

$(LAYERS_SENTINEL): $(BSP_TARBALL_PATH)
	@echo "==> Extracting $(BSP_TARBALL) → $(YOCTO_DIR)/ …"
	tar xjf $(BSP_TARBALL_PATH) -C $(YOCTO_DIR)/
	@echo "    ✓ BSP layers extracted"

$(BSP_TARBALL_PATH):
	@echo "ERROR: BSP tarball not found at $(BSP_TARBALL_PATH)"
	@echo "       Run 'make bsp-fetch' first, or place the tarball manually."
	@exit 1

# ---------------------------------------------------------------------------
#  Yocto build
# ---------------------------------------------------------------------------

.PHONY: yocto-check
yocto-check: $(LAYERS_SENTINEL) ## Validate Yocto layer configuration
	@echo "==> Checking layer configuration …"
	@bash -c 'source $(OE_INIT) $(BUILD_DIR) >/dev/null 2>&1 && bitbake-layers show-layers'
	@echo ""
	@echo "    ✓ Layer configuration OK"

.PHONY: yocto-init
yocto-init: $(LAYERS_SENTINEL) ## Print the command to source the Yocto build env
	@echo ""
	@echo "Run this in your shell (cannot be done from make):"
	@echo ""
	@echo "  source $(OE_INIT) $(BUILD_DIR)"
	@echo "  MACHINE=$(MACHINE) bitbake $(IMAGE)"
	@echo ""

.PHONY: yocto-build
yocto-build: $(LAYERS_SENTINEL) ## Build the Yocto image (MACHINE & IMAGE overridable)
	@echo "==> Building $(IMAGE) for MACHINE=$(MACHINE) …"
	@bash -c 'source $(OE_INIT) $(BUILD_DIR) && MACHINE=$(MACHINE) bitbake $(IMAGE)'
	@echo ""
	@echo "    ✓ Build complete. Artefacts in $(BUILD_DIR)/$(YOCTO_TMPDIR)/deploy/images/$(MACHINE)/"

# ---------------------------------------------------------------------------
#  Status & information
# ---------------------------------------------------------------------------

.PHONY: bsp-status
bsp-status: ## Show BSP file and layer status
	@echo ""
	@echo "BSP Tarball Staging (.release-staging/):"
	@if [ -d "$(STAGING_DIR)" ]; then \
		ls -lhS $(STAGING_DIR)/ 2>/dev/null || echo "  (empty)"; \
	else \
		echo "  (directory not found – run 'make bsp-fetch')"; \
	fi
	@echo ""
	@echo "Yocto Layers (yocto-bsp/layers/):"
	@if [ -d "$(LAYERS_DIR)" ]; then \
		ls -1d $(LAYERS_DIR)/*/ 2>/dev/null | sed 's|$(REPO_ROOT)/||' || echo "  (empty)"; \
	else \
		echo "  (not extracted)"; \
	fi
	@echo ""
	@if [ -f "$(OE_INIT)" ]; then \
		echo "  ✓ BSP layers are ready"; \
	else \
		echo "  ⚠ BSP layers not found – run 'make bsp-extract'"; \
	fi
	@echo ""
	@echo "Build Configuration:"
	@echo "  MACHINE = $(MACHINE)"
	@echo "  IMAGE   = $(IMAGE)"
	@echo ""
	@if [ -d "$(BUILD_DIR)/$(YOCTO_TMPDIR)/deploy/images/$(MACHINE)" ]; then \
		echo "  ✓ Build artefacts exist in $(BUILD_DIR)/$(YOCTO_TMPDIR)/deploy/images/$(MACHINE)/"; \
	else \
		echo "  ⚠ No build artefacts yet – run 'make yocto-build'"; \
	fi
	@echo ""

# ---------------------------------------------------------------------------
#  Cleanup
# ---------------------------------------------------------------------------

.PHONY: clean-bsp
clean-bsp: ## Remove extracted BSP layers (keeps tarballs)
	@echo "==> Removing extracted BSP layers …"
	rm -rf $(LAYERS_DIR)/openembedded-core
	rm -rf $(LAYERS_DIR)/meta-openembedded
	rm -rf $(LAYERS_DIR)/meta-qt5
	rm -rf $(LAYERS_DIR)/meta-st
	rm -rf $(LAYERS_DIR)/meta-myir-st
	@echo "    ✓ BSP layers removed"

.PHONY: clean-build
clean-build: ## Remove Yocto build artifacts (tmp-glibc/, cache/)
	@echo "==> Cleaning Yocto build directory …"
	rm -rf $(BUILD_DIR)/$(YOCTO_TMPDIR) $(BUILD_DIR)/cache
	@echo "    ✓ Build artifacts removed"

.PHONY: restructure
restructure: ## Run the cleanup & restructure script
	@echo "==> Running cleanup-and-restructure.sh …"
	$(SCRIPTS_DIR)/cleanup-and-restructure.sh
