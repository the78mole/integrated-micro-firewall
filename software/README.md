# Software Components

This directory contains all software components for the Integrated Micro Firewall.

## Directory Structure

```
software/
├── meta-imf/           # Custom Yocto layer
│   ├── conf/           # Layer and machine configuration
│   └── recipes-firewall/  # Firewall and VPN recipes
└── config/             # Runtime configuration templates
    ├── firewall/       # nftables rule sets
    └── wireguard/      # WireGuard configuration templates
```

## Getting Started

Refer to the [Yocto Build Guide](../docs/software/yocto-build.md) for instructions
on setting up the build environment and building the IMF image.

## Custom Yocto Layer: `meta-imf`

The `meta-imf` layer adds:

- IMF distro configuration (`imf`)
- `imf-image` minimal root filesystem image
- Firewall rule set provisioning recipes
- WireGuard tooling recipes

## Configuration Templates

Runtime configuration templates are provided in `config/`. These are intended to
be copied and customised for each deployment.
