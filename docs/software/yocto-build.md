# Yocto Build Guide

## Prerequisites

### Host System Requirements

| Requirement | Minimum |
|-------------|---------|
| OS | Ubuntu 20.04 LTS or 22.04 LTS (recommended) |
| RAM | 8 GB (16 GB recommended) |
| Disk | 100 GB free space |
| CPU cores | 4 (8+ recommended for faster builds) |

### Required Host Packages (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install -y \
    gawk wget git-core diffstat unzip texinfo gcc build-essential \
    chrpath socat cpio python3 python3-pip python3-pexpect \
    xz-utils debianutils iputils-ping python3-git python3-jinja2 \
    libegl1-mesa libsdl1.2-dev pylint xterm python3-subunit mesa-common-dev \
    zstd liblz4-tool
```

### Required CLI Tools

| Tool | Purpose |
|------|---------|
| `gh` | GitHub CLI – authentication |
| `oras` | OCI Registry As Storage – download vendor BSP tarballs |
| `make` | Build orchestration |

## Repository Layout

The Yocto BSP is fully contained in the repository. No external cloning is needed.

```
yocto-bsp/
├── build/
│   └── conf/
│       ├── bblayers.conf      # Layer configuration (pre-configured)
│       └── local.conf         # Machine / distro / build settings
└── layers/                    # Extracted from vendor BSP tarball
    ├── openembedded-core/     # OE-Core (meta) – base layer
    ├── meta-openembedded/     # meta-oe, meta-python, meta-networking, …
    ├── meta-qt5/              # Qt5 support layer
    ├── meta-st/               # ST BSP layers
    │   ├── meta-st-stm32mp/
    │   ├── meta-st-stm32mp-addons/
    │   └── meta-st-openstlinux/
    └── meta-myir-st/          # MYiR board-specific layer

software/
└── meta-imf/                  # IMF custom Yocto layer (project-specific)
    └── conf/layer.conf
```

### Layer Dependency Overview

The following layers are required and configured in `bblayers.conf`:

| Layer | Collection name | Source | Purpose |
|-------|----------------|--------|---------|
| `openembedded-core/meta` | `core` | BSP tarball | OE-Core base |
| `meta-openembedded/meta-oe` | `openembedded-layer` | BSP tarball | Common OE recipes |
| `meta-openembedded/meta-python` | `meta-python` | BSP tarball | Python packages |
| `meta-openembedded/meta-networking` | `networking-layer` | BSP tarball | Networking recipes |
| `meta-openembedded/meta-gnome` | | BSP tarball | GNOME dependencies |
| `meta-openembedded/meta-initramfs` | | BSP tarball | initramfs support |
| `meta-openembedded/meta-multimedia` | | BSP tarball | Multimedia support |
| `meta-openembedded/meta-webserver` | | BSP tarball | Web server recipes |
| `meta-openembedded/meta-filesystems` | | BSP tarball | Filesystem tools |
| `meta-openembedded/meta-perl` | | BSP tarball | Perl packages |
| `meta-st/meta-st-stm32mp` | `stm-st-stm32mp` | BSP tarball | ST STM32MP BSP |
| `meta-st/meta-st-stm32mp-addons` | `stm-st-stm32mp-mx` | BSP tarball | STM32MP CubeMX addons |
| `meta-st/meta-st-openstlinux` | `st-openstlinux` | BSP tarball | OpenSTLinux distro |
| `meta-qt5` | `qt5-layer` | BSP tarball | Qt5 framework |
| `meta-myir-st` | `stm-myir-st` | BSP tarball | MYiR board support |
| `software/meta-imf` | `meta-imf` | This repo | Custom firewall layer |

> **Important:** Layer dependencies use _collection names_, not directory names.
> For example, `meta-oe` has collection name `openembedded-layer`, and
> `meta-networking` has collection name `networking-layer`. Getting these wrong
> causes `Layer '…' depends on layer '…', but this layer is not enabled` errors.

## Building with Make (Recommended)

The project Makefile automates the entire workflow:

```bash
# 1. Authenticate with GHCR (one-time)
make bsp-login

# 2. Download vendor BSP tarballs (~360 MB)
make bsp-fetch

# 3. Extract BSP layers into yocto-bsp/layers/
make bsp-extract

# 4. Validate layer configuration
make yocto-check

# 5. Build the image
make yocto-build
```

### Overriding Build Parameters

```bash
# Build for eMMC variant
make yocto-build MACHINE=myd-yf13x-emmc

# Build a different image
make yocto-build IMAGE=myir-image-qt
```

### Available Machines

| MACHINE | Description |
|---------|-------------|
| `myd-yf13x` | MYD-YF13X development board (SD card boot, **default**) |
| `myd-yf13x-emmc` | MYD-YF13X with eMMC boot |
| `myd-yf13x-nand` | MYD-YF13X with NAND boot |

## Building Manually (Alternative)

If you prefer not to use the Makefile:

### 1. Extract BSP Layers

```bash
mkdir -p .release-staging
# Place or download yf13x-yocto-stm32mp1-5.15.67.tar.bz2 into .release-staging/
tar xjf .release-staging/yf13x-yocto-stm32mp1-5.15.67.tar.bz2 -C yocto-bsp/
```

### 2. Initialise the Build Environment

```bash
source yocto-bsp/layers/openembedded-core/oe-init-build-env yocto-bsp/build
```

> **Note:** `oe-init-build-env` changes your working directory to `yocto-bsp/build/`.

### 3. Verify Configuration

The `bblayers.conf` and `local.conf` in `yocto-bsp/build/conf/` are pre-configured
and checked into the repository. Verify the layer setup:

```bash
bitbake-layers show-layers
```

You should see all 16 layers listed.

### 4. Build

```bash
MACHINE=myd-yf13x bitbake myir-image-core
```

## Build Output

A successful build produces artefacts in:

```
yocto-bsp/build/tmp/deploy/images/myd-yf13x/
```

Key files include the root filesystem image, kernel, device tree, and
bootloader components for the STM32MP1 platform.

## Build Performance

| Setting | Variable | Default | Recommendation |
|---------|----------|---------|----------------|
| BitBake threads | `BB_NUMBER_THREADS` | auto | Number of CPU cores |
| Parallel make | `PARALLEL_MAKE` | auto | `-j <cores>` |
| Remove work dirs | `INHERIT += "rm_work"` | disabled | Enable to save disk |
| Download cache | `DL_DIR` | `${TOPDIR}/downloads` | Shared path across builds |
| Sstate cache | `SSTATE_DIR` | `${TOPDIR}/sstate-cache` | Shared path across builds |

Set these in `yocto-bsp/build/conf/local.conf`.

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| `Layer '…' depends on layer '…', but this layer is not enabled` | Missing layer in `bblayers.conf` or wrong `LAYERDEPENDS` collection name | Run `make yocto-check`; ensure `LAYERDEPENDS` uses collection names (`openembedded-layer`, not `meta-oe`) |
| `ERROR: Nothing PROVIDES '…'` | Missing layer or misspelled recipe | Verify `bblayers.conf` with `bitbake-layers show-layers` |
| `No bb files in default matched BBFILE_PATTERN_…` | Layer has no recipes yet | Informational warning; safe to ignore for empty custom layers |
| `Multiple providers are available for runtime …` | Two layers provide the same package | Add `PREFERRED_RPROVIDER_<pkg>` to `local.conf` |
| Fetch errors / `Failed to fetch URL` | Upstream mirror down or network issue | BitBake retries via `MIRRORS`; check `DL_DIR` |
| Out of disk space | Build cache growth (>50 GB) | Set `INHERIT += "rm_work"` in `local.conf` |
| Slow first build | No sstate cache, all 4000+ tasks from scratch | Expected; subsequent builds are much faster |

## Related Documents

- [Software Overview](software-overview.md)
- [System Architecture](../architecture/system-overview.md)
