# Software Overview

## Introduction

The Integrated Micro Firewall runs a minimal Embedded Linux image built with the
[Yocto Project](https://www.yoctoproject.org/). The image is tailored to the
MYC-YF13X SOM and provides only the services required for firewall and VPN operation.

## Software Stack

```
┌────────────────────────────────────────────┐
│           User Applications                │
│  nftables · WireGuard · ssh · chrony       │
├────────────────────────────────────────────┤
│           systemd (init system)            │
├────────────────────────────────────────────┤
│       GNU C Library (glibc / musl)         │
├────────────────────────────────────────────┤
│   Linux Kernel (with MYiR BSP patches)     │
├────────────────────────────────────────────┤
│   U-Boot Bootloader (MYiR BSP)             │
├────────────────────────────────────────────┤
│          MYC-YF13X Hardware                │
└────────────────────────────────────────────┘
```

## Yocto Build System

The image is built using the Yocto Project (currently targeting the **Kirkstone**
LTS release). The MYiR-provided BSP layer (`meta-myir`) supplies the machine
configuration, U-Boot, and kernel for the MYC-YF13X SOM.

The custom layer `meta-imf` (located in [`software/meta-imf/`](../../software/meta-imf/))
adds:

- IMF machine configuration (based on the MYiR machine)
- `imf-image` – the minimal root filesystem image
- Recipes for nftables rule set provisioning
- WireGuard kernel module and tools
- SSH hardening configuration

### Layers

| Layer | Source | Purpose |
|-------|--------|---------|
| `meta` | Yocto (poky) | Core OE metadata |
| `meta-poky` | Yocto (poky) | Poky distro configuration |
| `meta-oe` | meta-openembedded | Extended package collection |
| `meta-networking` | meta-openembedded | Networking tools (nftables, WireGuard) |
| `meta-myir` | MYiR BSP | SOM BSP (U-Boot, kernel, drivers) |
| `meta-imf` | This repository | IMF-specific image and configuration |

### Image: `imf-image`

The `imf-image` produces a minimal read-only root filesystem containing:

- Linux kernel + NXP i.MX6ULL device tree
- Busybox + essential utilities
- nftables + nft tooling
- WireGuard kernel module + `wg` and `wg-quick` tools
- OpenSSH server (key-based authentication only)
- chrony (NTP client)

Excluded on purpose (to minimise attack surface):
- Package manager (no `opkg` / `apt`)
- Compiler toolchain
- Python / scripting runtimes
- Any GUI or display stack

## Firewall Configuration

nftables rule sets are stored in [`software/config/firewall/`](../../software/config/firewall/).
The rule set implements:

1. **Default-deny** on all chains.
2. **Stateful tracking** (connection tracking) for established/related traffic.
3. **Management access**: TCP port 443 and 22 are accessible on ETH0 only from the
   WireGuard tunnel interface.
4. **WireGuard ingress**: UDP port 51820 accepted on ETH1.
5. **ICMP**: Echo-request allowed on both interfaces for diagnostics.

See [Use Case: HP iLO Protection](../use-cases/hp-ilo-protection.md) for a
concrete rule set example.

## VPN: WireGuard

WireGuard configuration templates are located in
[`software/config/wireguard/`](../../software/config/wireguard/).

Key design decisions:

- The IMF acts as the WireGuard **server** (responder).
- Remote administrators install WireGuard on their workstation (initiator).
- All management traffic to the iLO network is tunnelled through WireGuard.
- Pre-shared keys are optionally used for defence-in-depth.

## Update Strategy

- Full image updates are delivered as signed, compressed images written to an
  alternate boot partition (A/B update scheme).
- Configuration updates (firewall rules, WireGuard peers) are applied via a
  dedicated configuration partition mounted read-write.

## Related Documents

- [System Architecture](../architecture/system-overview.md)
- [Yocto Build Guide](yocto-build.md)
- [Hardware Overview](../hardware/hardware-overview.md)
- [Use Case: HP iLO Protection](../use-cases/hp-ilo-protection.md)
