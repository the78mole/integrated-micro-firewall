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

## Repository Layout

```
build/
├── conf/
│   ├── bblayers.conf   # Layer configuration
│   └── local.conf      # Machine / distro / build settings
└── downloads/          # Shared download cache (optional, set via DL_DIR)

sources/
├── poky/               # Yocto poky (kirkstone branch)
├── meta-openembedded/  # meta-oe, meta-networking (kirkstone branch)
├── meta-myir/          # MYiR BSP layer (from MYiR GitHub)
└── meta-imf/           # IMF custom layer (this repository: software/meta-imf/)
```

## Setting Up the Build Environment

### 1. Clone the Required Sources

```bash
mkdir -p ~/imf-build/sources
cd ~/imf-build/sources

# Yocto Poky
git clone -b kirkstone https://git.yoctoproject.org/poky

# OpenEmbedded layers
git clone -b kirkstone https://github.com/openembedded/meta-openembedded

# MYiR BSP (replace URL with the actual MYiR repository URL)
git clone -b kirkstone https://github.com/MYiRTech/meta-myir-imx

# IMF custom layer (from this repository)
ln -s /path/to/integrated-micro-firewall/software/meta-imf \
      ~/imf-build/sources/meta-imf
```

### 2. Initialise the Build Directory

```bash
cd ~/imf-build
source sources/poky/oe-init-build-env build
```

### 3. Configure `bblayers.conf`

Edit `build/conf/bblayers.conf` to include all required layers:

```bitbake
BBLAYERS ?= " \
  ${TOPDIR}/../sources/poky/meta \
  ${TOPDIR}/../sources/poky/meta-poky \
  ${TOPDIR}/../sources/meta-openembedded/meta-oe \
  ${TOPDIR}/../sources/meta-openembedded/meta-networking \
  ${TOPDIR}/../sources/meta-myir-imx \
  ${TOPDIR}/../sources/meta-imf \
  "
```

### 4. Configure `local.conf`

Add or modify the following settings in `build/conf/local.conf`:

```bitbake
# Target machine
MACHINE = "myc-yf13x"

# Distribution
DISTRO = "imf"

# Parallel build options (adjust to your host)
BB_NUMBER_THREADS = "8"
PARALLEL_MAKE = "-j 8"

# Optional: shared download and sstate cache directories
# DL_DIR = "/shared/yocto/downloads"
# SSTATE_DIR = "/shared/yocto/sstate-cache"
```

## Building the Image

```bash
cd ~/imf-build
source sources/poky/oe-init-build-env build

bitbake imf-image
```

A successful build produces artefacts in:

```
build/tmp/deploy/images/myc-yf13x/
├── imf-image-myc-yf13x.wic.gz   # Full disk image (SD card / eMMC)
├── imf-image-myc-yf13x.tar.gz   # Root filesystem archive
├── uImage                        # Linux kernel image
├── myc-yf13x.dtb                 # Device tree blob
└── u-boot.imx                    # U-Boot SPL + proper U-Boot
```

## Flashing the Image

### SD Card

```bash
# Decompress and write the WIC image to an SD card (replace /dev/sdX)
zcat build/tmp/deploy/images/myc-yf13x/imf-image-myc-yf13x.wic.gz \
  | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync
sync
```

### eMMC (via U-Boot)

Refer to the MYiR MYC-YF13X hardware manual for the boot-mode switch settings
required to enter the USB mass-storage / fastboot flash mode.

## SDK / Toolchain (Optional)

To build a standalone cross-compilation toolchain for application development:

```bash
bitbake imf-image -c populate_sdk
```

The installer is placed in `build/tmp/deploy/sdk/`.

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| `ERROR: Nothing PROVIDES ...` | Missing layer or misspelled recipe | Verify `bblayers.conf` |
| Fetch errors | Network issue or wrong URI | Check `DL_DIR`; use a mirror |
| Out of disk space | Build cache growth | Set `INHERIT += "rm_work"` in `local.conf` |
| Slow build | Default thread count | Increase `BB_NUMBER_THREADS` / `PARALLEL_MAKE` |

## Related Documents

- [Software Overview](software-overview.md)
- [System Architecture](../architecture/system-overview.md)
