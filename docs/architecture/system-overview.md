# System Architecture Overview

## Introduction

The Integrated Micro Firewall (IMF) is a small, embedded Linux-based firewall device
that is physically installed in a standard PCIe slot of a server. Its primary goal is
to secure management interfaces (e.g., HP iLO) that are directly reachable from an
external network by inserting a dedicated, independently-managed security layer between
the management interface and the external network.

## System Block Diagram

```
┌─────────────────────────────────────────────────────────┐
│                      Host Server                        │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │              PCIe Add-in Card (IMF)              │   │
│  │                                                  │   │
│  │   ┌────────────────────────────────────────┐    │   │
│  │   │          MYC-YF13X SOM                 │    │   │
│  │   │  (NXP i.MX6ULL / i.MX7ULP based)      │    │   │
│  │   │                                        │    │   │
│  │   │  ┌─────────┐        ┌───────────────┐  │    │   │
│  │   │  │ ETH0    │        │ ETH1          │  │    │   │
│  │   │  │ (iLO    │        │ (External     │  │    │   │
│  │   │  │  side)  │        │  Network)     │  │    │   │
│  │   │  └────┬────┘        └──────┬────────┘  │    │   │
│  │   └───────┼─────────────────── ┼───────────┘    │   │
│  │           │                    │                 │   │
│  │     PCIe power supply          │                 │   │
│  └──────────────────────────────────────────────────┘   │
│                                                         │
│  ┌────────────┐                                         │
│  │  HP iLO    │◄──────── ETH0                           │
│  └────────────┘                                         │
└─────────────────────────────────────────────────────────┘
                                         │
                                      ETH1
                                         │
                              ┌──────────▼──────────┐
                              │  External Network   │
                              │  (Internet / VLAN)  │
                              └─────────────────────┘
```

## Key Components

### Hardware

| Component | Description |
|-----------|-------------|
| PCIe Add-in Card | Custom carrier board that draws power from the host PCIe slot and provides mechanical integration |
| SOM | MYC-YF13X (MYiR), based on NXP i.MX6ULL or i.MX7ULP |
| ETH0 | Internal Ethernet – connects to HP iLO (or any other management interface) |
| ETH1 | External Ethernet – connects to the external / untrusted network |

### Software

| Component | Description |
|-----------|-------------|
| Embedded Linux | Yocto-based Linux image built with MYiR's BSP |
| Firewall | nftables rule set enforcing strict ingress/egress filtering |
| VPN | WireGuard endpoint for encrypted, authenticated remote access |
| Management | SSH access restricted to the VPN tunnel |

## Network Segments

The IMF creates two distinct network segments:

| Segment | Interface | Network (Example) | Description |
|---------|-----------|-------------------|-------------|
| Management | ETH0 | 192.168.100.0/24 | iLO and other BMC interfaces |
| External | ETH1 | DHCP / static | Uplink to data-centre network or internet |

Traffic is **not forwarded** between segments unless explicitly permitted by the
nftables rule set. By default, only VPN-authenticated clients may reach the
management segment.

## Security Layers

1. **Physical isolation**: The firewall runs on dedicated hardware independent of the host OS.
2. **Network segmentation**: Two separate Ethernet segments with explicit forwarding rules.
3. **Stateful packet filtering**: nftables with connection tracking.
4. **Encrypted remote access**: WireGuard VPN; only enrolled peers can initiate sessions.
5. **Minimal attack surface**: Read-only root filesystem; only required services enabled.

## Boot Sequence

1. PCIe slot provides 3.3 V / 12 V to the IMF carrier board.
2. The carrier board regulates power for the SOM.
3. U-Boot loads the Linux kernel and device tree from eMMC / SD.
4. The Yocto-generated root filesystem is mounted.
5. `systemd` starts the nftables firewall, WireGuard, and SSH services.

## Related Documents

- [Hardware Overview](../hardware/hardware-overview.md)
- [Software Overview](../software/software-overview.md)
- [Yocto Build Guide](../software/yocto-build.md)
- [Use Case: HP iLO Protection](../use-cases/hp-ilo-protection.md)
