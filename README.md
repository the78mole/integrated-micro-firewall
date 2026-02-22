# Integrated Micro Firewall

This project implements a stand-alone micro-firewall based on Embedded Linux, integrated on a PCIe add-in card. It is designed to protect management interfaces (e.g., HP iLO) on externally hosted servers by controlling and restricting access from external networks using firewall rules and/or a WireGuard VPN endpoint.

## Overview

The Integrated Micro Firewall (IMF) consists of:

- **Hardware**: A PCIe add-in card that provides power from the host's PCIe slot and exposes two external Ethernet interfaces.
- **Software**: An Embedded Linux system based on [Yocto Project](https://www.yoctoproject.org/) and the MYiR BSP, running on the [MYC-YF13X SOM](https://www.myirtech.com/list.asp?id=586).

## Primary Use Case

Securing the HP iLO (Integrated Lights-Out) management interface of a server hosted in an external data centre:

- One Ethernet port connects to the iLO interface.
- A second Ethernet port connects to the external (untrusted) network.
- The firewall enforces access control between these two segments, optionally providing a WireGuard VPN endpoint for secure remote access.

## Repository Structure

```
integrated-micro-firewall/
├── docs/                        # Project documentation
│   ├── architecture/            # System architecture
│   ├── hardware/                # Hardware documentation
│   ├── software/                # Software documentation
│   └── use-cases/               # Use-case descriptions
├── hardware/                    # Hardware design files
│   ├── pcb/                     # PCB layout and schematics (KiCad)
│   └── bom/                     # Bill of materials
├── software/                    # Software components
│   ├── meta-imf/                # Custom Yocto layer
│   └── config/                  # Runtime configuration templates
│       ├── firewall/            # nftables / iptables rule sets
│       └── wireguard/           # WireGuard configuration templates
└── scripts/                     # Build and deployment helper scripts
```

## Documentation

- [System Architecture](docs/architecture/system-overview.md)
- [Hardware Overview](docs/hardware/hardware-overview.md)
- [Software Overview](docs/software/software-overview.md)
- [Yocto Build Guide](docs/software/yocto-build.md)
- [Use Case: HP iLO Protection](docs/use-cases/hp-ilo-protection.md)

## Quick Start – Building `myir-image-core`

### Prerequisites

| Requirement | Minimum |
|-------------|---------|
| OS | Ubuntu 20.04 / 22.04 LTS |
| RAM | 8 GB (16 GB recommended) |
| Disk | 100 GB free space |
| Tools | `git`, `make`, `oras`, `gh` CLI |

Install the Yocto host dependencies:

```bash
sudo apt-get install -y \
    gawk wget git diffstat unzip texinfo gcc build-essential \
    chrpath socat cpio python3 python3-pip python3-pexpect \
    xz-utils debianutils iputils-ping python3-git python3-jinja2 \
    libegl1-mesa libsdl1.2-dev xterm python3-subunit mesa-common-dev \
    zstd liblz4-tool
```

### Build Steps

```bash
# 1. Authenticate with GHCR (one-time, requires `gh auth login` first)
make bsp-login

# 2. Download the vendor BSP tarballs from GHCR
make bsp-fetch

# 3. Extract the Yocto BSP layers (automatic if needed)
make bsp-extract

# 4. Validate the layer configuration (optional but recommended)
make yocto-check

# 5. Build the image (takes several hours on a first build)
make yocto-build
```

The default build targets machine **`myd-yf13x`** and image **`myir-image-core`**.
Override via:

```bash
make yocto-build MACHINE=myd-yf13x-emmc IMAGE=myir-image-core
```

### Available Machines

| MACHINE | Description |
|---------|-------------|
| `myd-yf13x` | MYD-YF13X development board (SD card boot, default) |
| `myd-yf13x-emmc` | MYD-YF13X with eMMC boot |
| `myd-yf13x-nand` | MYD-YF13X with NAND boot |

### Build Artefacts

After a successful build, images are in:

```
yocto-bsp/build/tmp-glibc/deploy/images/myd-yf13x/
```

### All Make Targets

```bash
make help
```

## License

See [LICENSE](LICENSE) for details.

