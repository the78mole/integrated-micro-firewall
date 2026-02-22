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
yocto-bsp/build/tmp-glibc/deploy/images/myd-yf13x/
```

> **Note:** The directory is `tmp-glibc` (not `tmp`) because `DISTRO = "nodistro"`
> sets `TCLIBC = "glibc"`, which causes BitBake to use `TMPDIR = tmp-glibc`.

### Key Artefacts

| File | Description |
|------|-------------|
| `myir-image-core-myd-yf13x.ext4` | Root filesystem (ext4) |
| `myir-image-core-myd-yf13x.tar.xz` | Root filesystem (tarball) |
| `st-image-bootfs-nodistro-myd-yf13x.ext4` | Boot partition (kernel + device tree) |
| `st-image-vendorfs-nodistro-myd-yf13x.ext4` | Vendor filesystem |
| `st-image-userfs-nodistro-myd-yf13x.ext4` | User data filesystem |
| `arm-trusted-firmware/tf-a-*.stm32` | TF-A first-stage bootloader |
| `fip/fip-*.bin` | FIP image (OP-TEE + U-Boot) |

### Flash Layouts

The build generates TSV flash layout files for use with **STM32CubeProgrammer**:

```
flashlayout_myir-image-core/optee/
├── FlashLayout_sdcard_myb-stm32mp135x-256m-optee.tsv
├── FlashLayout_sdcard_myb-stm32mp135x-512m-optee.tsv
├── FlashLayout_emmc_myb-stm32mp135x-256m-optee.tsv
└── FlashLayout_emmc_myb-stm32mp135x-512m-optee.tsv
```

| Flash Layout | Target | RAM |
|--------------|--------|-----|
| `FlashLayout_sdcard_…-256m-optee.tsv` | SD card | 256 MB |
| `FlashLayout_sdcard_…-512m-optee.tsv` | SD card | 512 MB |
| `FlashLayout_emmc_…-256m-optee.tsv` | eMMC | 256 MB |
| `FlashLayout_emmc_…-512m-optee.tsv` | eMMC | 512 MB |

Choose the layout matching your board's RAM size and target storage medium.

## Flashing the Image

Flashing uses **STM32CubeProgrammer** with the board in **USB DFU mode**.

### Prerequisites

- Install [STM32CubeProgrammer](https://www.st.com/en/development-tools/stm32cubeprog.html) (v2.13+)
- Connect the board via USB to the host
- Set the board's boot switches to USB DFU mode (refer to the MYiR MYD-YF13X hardware manual)

### Flash to SD Card

```bash
STM32_Programmer_CLI -c port=usb1 -w \
  flashlayout_myir-image-core/optee/FlashLayout_sdcard_myb-stm32mp135x-512m-optee.tsv
```

### Flash to eMMC

```bash
STM32_Programmer_CLI -c port=usb1 -w \
  flashlayout_myir-image-core/optee/FlashLayout_emmc_myb-stm32mp135x-512m-optee.tsv
```

> **Note:** Run the commands from the `tmp-glibc/deploy/images/myd-yf13x/` directory,
> as the TSV files reference image paths relative to that location.

### Partition Layout (SD Card Example)

The flash layout writes the following partitions:

| # | Name | Type | Content |
|---|------|------|---------|
| 1 | fsbl1 | Binary | `tf-a-…-sdcard.stm32` (first-stage bootloader) |
| 2 | fsbl2 | Binary | `tf-a-…-sdcard.stm32` (backup copy) |
| 3 | metadata1/2 | Binary | `metadata.bin` (A/B boot metadata) |
| 4 | fip-a | FIP | `fip-…-optee.bin` (OP-TEE + U-Boot) |
| 5 | bootfs | ext4 | Kernel, device trees (`st-image-bootfs`) |
| 6 | vendorfs | ext4 | Vendor data (`st-image-vendorfs`) |
| 7 | rootfs | ext4 | Root filesystem (`myir-image-core`) |
| 8 | userfs | ext4 | User data (`st-image-userfs`) |

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
| `Unable to find revision … in branch master` | Upstream repo renamed default branch (e.g. `master` → `main`) | Create a `.bbappend` in `meta-imf` overriding `SRC_URI` with the correct `branch=` (see `recipes-support/libiio/libiio_git.bbappend` for an example) |
| Out of disk space | Build cache growth (>50 GB) | Set `INHERIT += "rm_work"` in `local.conf` |
| Slow first build | No sstate cache, all 4000+ tasks from scratch | Expected; subsequent builds are much faster |

## Related Documents

- [Software Overview](software-overview.md)
- [System Architecture](../architecture/system-overview.md)
