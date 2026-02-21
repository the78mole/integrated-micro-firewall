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

## License

See [LICENSE](LICENSE) for details.

