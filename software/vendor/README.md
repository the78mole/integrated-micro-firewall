# Vendor BSP Files

The MYiR STM32MP13X BSP tarballs are **not tracked in Git** due to their size (~15 GB).
They are stored as OCI artifacts in the [GitHub Container Registry (GHCR)](https://github.com/the78mole/integrated-micro-firewall/pkgs/container/).

## Download

### Prerequisites

1. Install [`oras`](https://oras.land/docs/installation):
   ```bash
   curl -fSL https://github.com/oras-project/oras/releases/download/v1.3.0/oras_1.3.0_linux_amd64.tar.gz \
     | sudo tar xz -C /usr/local/bin oras
   ```

2. Authenticate with GHCR (uses your existing `gh` login):
   ```bash
   gh auth token | oras login ghcr.io -u <your-username> --password-stdin
   ```

### Fetch all BSP files

```bash
./scripts/fetch-vendor-bsp.sh
```

Files are downloaded to `software/vendor/bsp/`.

### Manual pull (single package)

```bash
oras pull ghcr.io/the78mole/integrated-micro-firewall/vendor-bsp/<package-name>:1.0
```

## Available packages

| OCI Package | File | Size | Description |
|-------------|------|------|-------------|
| `vendor-bsp/yocto-qt-downloads` | `Yocto-qt-downloads.tar.xz` | 13 GB | Yocto DL_DIR cache (optional) |
| `vendor-bsp/myir-stm32-kernel` | `MYiR-STM32-kernel.tar.bz2` | 385 MB | Linux kernel source |
| `vendor-bsp/myir-stm32-u-boot` | `MYiR-STM32-u-boot.tar.bz2` | 191 MB | U-Boot source |
| `vendor-bsp/yf13x-yocto-stm32mp1-5-15-67` | `yf13x-yocto-stm32mp1-5.15.67.tar.bz2` | 360 MB | Yocto BSP layer |
| `vendor-bsp/myir-stm32-tf-a` | `MYiR-STM32-tf-a.tar.bz2` | 31 MB | TF-A (ARM Trusted Firmware) |
| `vendor-bsp/myir-stm32-optee` | `MYiR-STM32-optee.tar.bz2` | 22 MB | OP-TEE |
| `vendor-bsp/mxapp2` | `mxapp2.tar.gz` | 31 MB | Demo application |
| `vendor-bsp/sdk-qt` | `sdk-qt.tar.xz` | 1.2 GB | Qt cross-compilation SDK |
