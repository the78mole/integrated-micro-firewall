# Build and Deployment Scripts

This directory contains helper scripts for building the Yocto image and
deploying it to the IMF hardware.

## Scripts

| Script | Description |
|--------|-------------|
| *(to be added)* | |

## Usage

Refer to the [Yocto Build Guide](../docs/software/yocto-build.md) for manual
build instructions.

Helper scripts will be added here as the project matures. Planned scripts:

| Script | Purpose |
|--------|---------|
| `setup-build-env.sh` | Clone all required Yocto layers and initialise the build directory |
| `flash-sd.sh` | Write the built WIC image to an SD card |
| `update-firewall-rules.sh` | Push an updated `nftables.conf` to a running IMF over SSH |
| `add-wireguard-peer.sh` | Add a new WireGuard peer to the IMF configuration |
