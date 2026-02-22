#!/usr/bin/env bash
# =============================================================================
# fetch-vendor-bsp.sh
#
# Downloads MYiR STM32MP13X vendor BSP files from GitHub Container Registry
# (GHCR) using oras. These files are too large to track in Git.
#
# Prerequisites:
#   - oras CLI (https://oras.land/docs/installation)
#   - Authentication: gh auth token | oras login ghcr.io -u <user> --password-stdin
# =============================================================================
set -euo pipefail

REPO_OWNER="the78mole"
REPO_NAME="integrated-micro-firewall"
REGISTRY="ghcr.io/${REPO_OWNER}/${REPO_NAME}/vendor-bsp"
TAG="1.0"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BSP_DIR="$REPO_ROOT/software/vendor/bsp"

mkdir -p "$BSP_DIR"

# Map: OCI package name -> original filename
# Format: "oci-package-name|original-filename"
PACKAGES=(
    "myir-stm32-kernel|MYiR-STM32-kernel.tar.bz2"
    "myir-stm32-u-boot|MYiR-STM32-u-boot.tar.bz2"
    "myir-stm32-tf-a|MYiR-STM32-tf-a.tar.bz2"
    "myir-stm32-optee|MYiR-STM32-optee.tar.bz2"
    "yf13x-yocto-stm32mp1-5-15-67|yf13x-yocto-stm32mp1-5.15.67.tar.bz2"
    "mxapp2|mxapp2.tar.gz"
    "sdk-qt|sdk-qt.tar.xz"
    # Uncomment the next line only if you need the full Yocto DL cache (~13 GB):
    # "yocto-qt-downloads|Yocto-qt-downloads.tar.xz"
)

# Check for oras
if ! command -v oras &>/dev/null; then
    echo "ERROR: 'oras' CLI not found. Install from https://oras.land/docs/installation"
    echo "  Quick install: curl -fSL https://github.com/oras-project/oras/releases/download/v1.3.0/oras_1.3.0_linux_amd64.tar.gz | sudo tar xz -C /usr/local/bin oras"
    exit 1
fi

echo "============================================"
echo "Fetching vendor BSP from GHCR (OCI)"
echo "Registry: ${REGISTRY}"
echo "Tag:      ${TAG}"
echo "Target:   ${BSP_DIR}"
echo "============================================"
echo ""

for entry in "${PACKAGES[@]}"; do
    pkg_name="${entry%%|*}"
    filename="${entry##*|}"
    dest="$BSP_DIR/$filename"
    ref="${REGISTRY}/${pkg_name}:${TAG}"

    if [[ -f "$dest" ]]; then
        echo "  SKIP (exists): $filename"
        continue
    fi

    echo "  PULL: $ref"
    echo "     -> $filename"
    (cd "$BSP_DIR" && oras pull "$ref") || {
        echo "  FAIL: Could not pull $pkg_name"
        continue
    }
    echo "  OK"
    echo ""
done

echo ""
echo "Done. BSP files are in: $BSP_DIR"
