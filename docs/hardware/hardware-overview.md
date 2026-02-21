# Hardware Overview

## PCIe Add-in Card

The Integrated Micro Firewall is built around a custom PCIe add-in card. The card
occupies a standard PCIe x1 (or larger) slot in any ATX or server-format motherboard.
No PCIe data lanes are used; the slot is used **only for power supply**.

### Power Supply

The PCIe connector provides:

| Rail | Typical current draw | Usage |
|------|----------------------|-------|
| +3.3 V | ≤ 500 mA | SOM I/O, logic |
| +12 V | ≤ 300 mA | DC-DC conversion for SOM core |

The carrier board includes DC-DC converters to generate all voltages required by the
MYC-YF13X SOM (typically 3.3 V, 1.8 V, 1.5 V, 1.1 V).

### Mechanical

- Form factor: Low-profile PCIe add-in card (LP bracket included)
- Slot requirement: ≥ PCIe x1 (any generation)
- External connectors: 2× RJ-45 (Ethernet) accessible from the rear bracket

## System-on-Module (SOM): MYC-YF13X

The SOM is produced by [MYiR Technology](https://www.myirtech.com/) and is based on
the NXP i.MX6ULL or i.MX7ULP application processor.

### Key SOM Specifications

| Parameter | Value |
|-----------|-------|
| Vendor | MYiR Technology |
| Model | MYC-YF13X |
| CPU | NXP i.MX6ULL (Cortex-A7, up to 800 MHz) |
| RAM | 256 MB DDR3L (on-module) |
| Flash | 256 MB NAND / 4 GB eMMC (option) |
| Ethernet MACs | 2× 10/100 Mbps |
| OS support | Linux (Yocto / Buildroot) |
| Form factor | stamp-hole SMD |

### SOM Pin Usage on Carrier Board

| SOM signal | Carrier usage |
|------------|---------------|
| ENET1 | ETH0 – iLO-side RJ-45 |
| ENET2 | ETH1 – external-network RJ-45 |
| UART1 | Debug console (3.3 V TTL header, not exposed on bracket) |
| SD / eMMC | Boot media |
| USB OTG | Optional manufacturing / recovery port |

## Ethernet Interfaces

| Port | Label | Purpose |
|------|-------|---------|
| ETH0 | `eth0` (Linux) | Connected to HP iLO / management interface of host server |
| ETH1 | `eth1` (Linux) | Connected to external network (data-centre uplink / internet) |

Both ports use standard magnetics integrated in the RJ-45 connector (Integrated
Magnetics Jack).

## PCB Design

PCB design files (KiCad format) are located in the [`hardware/pcb/`](../../hardware/pcb/)
directory. The bill of materials (BOM) is maintained in
[`hardware/bom/`](../../hardware/bom/).

### Design Constraints

- PCB layers: 4-layer stack-up (signal, ground, power, signal)
- Impedance-controlled traces for Ethernet differential pairs (100 Ω differential)
- ESD protection on all external connectors
- Thermal design: passive cooling, no fan required

## Environmental Specifications

| Parameter | Value |
|-----------|-------|
| Operating temperature | 0 °C … +70 °C (commercial) |
| Storage temperature | -40 °C … +85 °C |
| Humidity | 5 % … 95 % RH, non-condensing |

## Related Documents

- [System Architecture](../architecture/system-overview.md)
- [Software Overview](../software/software-overview.md)
