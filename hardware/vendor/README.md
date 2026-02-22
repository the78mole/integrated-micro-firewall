# Vendor Hardware Reference

This directory contains vendor reference data for the Integrated Micro Firewall project.

## Directory Structure

```
vendor/
├── README.md           ← This file (SOM comparison & sourcing notes)
├── myir/               ← MYiR MYC-YF13X reference data (current SOM)
│   └── ...             (schematics, Gerber, datasheets, manuals)
└── other/              ← Datasheets for alternative SOMs
    ├── digi-connectcore-mp133-development-kit-datasheet.pdf
    ├── digi-connectcore-mp1.pdf
    ├── connectcore-8x-ds.pdf
    ├── stm32mp133c.pdf
    └── L-1061e.A0_phyCORE-AM62Ax_DSC_HW Manual.pdf
```

---

# Alternative System-on-Modules (SOMs)

The Integrated Micro Firewall currently uses the **MYiR MYC-YF13X** SOM (STM32MP135).
This section lists alternative SOMs that could serve as drop-in or redesign candidates.

## Requirements

Any replacement SOM must meet these minimum requirements:

| Requirement | Value |
|-------------|-------|
| Ethernet MACs | ≥ 2× (10/100 Mbps minimum) |
| RAM | ≥ 128 MB |
| Flash | ≥ 256 MB NAND or eMMC |
| Linux support | Yocto or Buildroot BSP available |
| Power | ≤ 3 W total (PCIe slot powered) |
| Form factor | Compact SMD module (stamp-hole or board-to-board) |

## Candidates

### STM32MP1-based

| Module | Vendor | Processor | Ethernet | RAM | Notes |
|--------|--------|-----------|----------|-----|-------|
| MYC-YF13X | MYiR | STM32MP135 (Cortex-A7 @ 1 GHz) | 2× GbE | 256 MB DDR3L | **Current choice**. Stamp-hole mount, Yocto BSP provided. Dual Gigabit Ethernet is ideal for the firewall use case. |
| STM32MP157F-DK2 | ST (reference) | STM32MP157 (2× Cortex-A7 @ 800 MHz + Cortex-M4) | 1× GbE | 512 MB DDR3L | Reference design only (not a SOM). Needs second Ethernet via USB or SPI adapter. Dual-core A7 offers more compute headroom. |
| OSD32MP1-BRK | Octavo Systems | STM32MP157 | 1× GbE | 512 MB DDR3L | SiP (System-in-Package) with integrated PMIC and DDR. Only 1× Ethernet MAC — would require USB-Ethernet or SPI-Ethernet for second port. |

### NXP i.MX-based

| Module | Vendor | Processor | Ethernet | RAM | Notes |
|--------|--------|-----------|----------|-----|-------|
| MYC-Y6ULX | MYiR | i.MX6ULL (Cortex-A7 @ 800 MHz) | 2× 10/100 | 256 MB–512 MB DDR3L | Pin-compatible variant of the YF13X for earlier i.MX6ULL designs. Proven Yocto support. Only 100 Mbps Ethernet. |
| DART-6ULL | Variscite | i.MX6ULL (Cortex-A7 @ 900 MHz) | 2× 10/100 | up to 512 MB DDR3L | Board-to-board connectors, small form factor. Well-maintained Yocto BSP. Commercial and industrial temp options. |
| DART-6UL | Variscite | i.MX6UL (Cortex-A7 @ 528 MHz) | 2× 10/100 | up to 512 MB DDR3L | Lower-cost / lower-power variant of the DART-6ULL. Same Yocto BSP as DART-6ULL. |
| SOM-iMX6ULL | Compulab | i.MX6ULL (Cortex-A7 @ 900 MHz) | 2× 10/100 | up to 512 MB DDR3L | Long lifecycle design. Compulab provides Ubuntu & Yocto BSP. Higher price point. |

### TI Sitara-based

| Module | Vendor | Processor | Ethernet | RAM | Notes |
|--------|--------|-----------|----------|-----|-------|
| OSD335x | Octavo Systems | AM335x (Cortex-A8 @ 1 GHz) | 2× GbE (PRU-ICSS) | 512 MB DDR3L | SiP with integrated DDR, PMIC, passives. Dual Gigabit Ethernet via PRU-ICSS. Larger community (BeagleBone ecosystem). Somewhat higher power draw. |
| MYC-C437X | MYiR | AM437x (Cortex-A9 @ 1 GHz) | 2× GbE (PRU-ICSS) | 512 MB DDR3L | Same vendor as current SOM, easier logistics. PRU-ICSS enables Gigabit Ethernet. More processing power than i.MX6ULL. |
| phyCORE-AM335x | Phytec | AM335x (Cortex-A8 @ 1 GHz) | 2× GbE (PRU-ICSS) | up to 512 MB DDR3L | Industrial-grade, long-term availability (15+ years). Higher price. Excellent Yocto (meta-phytec) support. |

### Microchip / Other

| Module | Vendor | Processor | Ethernet | RAM | Notes |
|--------|--------|-----------|----------|-----|-------|
| ATSAMA5D27-SOM1 | Microchip | SAMA5D27 (Cortex-A5 @ 500 MHz) | 2× 10/100 | 128 MB DDR2 | Very low power. Two Ethernet MACs built-in. Mainline Linux support. Limited performance for high-throughput filtering. |
| SAM9X75-SOM | Microchip | SAM9X75 (Cortex-A5 @ 800 MHz) | 1× GbE + 1× 10/100 | 256 MB DDR3L | Newer Microchip platform with mixed-speed Ethernet. Good mainline support. |

## Availability & Documentation

| Vendor | Distribution | Single-unit availability | Documentation quality |
|--------|-------------|--------------------------|----------------------|
| **MYiR** | Mouser, direct | ✅ Excellent (Mouser stock, DevKit available) | ✅ Very comprehensive (schematics, Gerber, datasheets, Yocto BSP) |
| **Digi International** | Mouser, DigiKey | ✅ Good (Mouser stock) | ⚠️ Problematic (incomplete, hard to navigate) |
| **Phytec** | Direct from Phytec only | ⚠️ Direct sales only (no distributor stock) | ✅ Excellent (detailed manuals, well-maintained meta-phytec Yocto layer) |
| **Variscite** | Direct, some distributors | ⚠️ Limited single-unit (MOQ-oriented) | ✅ Good (Yocto BSP, wiki) |
| **Octavo Systems** | Mouser, DigiKey | ✅ Good | ✅ Good (reference designs, community) |
| **Microchip** | Mouser, DigiKey | ✅ Excellent | ✅ Good (mainline Linux, MPLAB ecosystem) |

## Comparison Summary

| Criterion | MYC-YF13X (current) | DART-6ULL | OSD335x | ATSAMA5D27-SOM1 |
|-----------|---------------------|-----------|---------|------------------|
| Dual Ethernet | ✅ 2× GbE | ✅ 2× 100M | ✅ 2× GbE | ✅ 2× 100M |
| Performance | Good | Good | Better | Lower |
| Power | Low (~1 W) | Low (~1 W) | Medium (~2 W) | Very low (~0.5 W) |
| Yocto BSP | Vendor | Vendor | Community + Vendor | Mainline |
| Single-unit avail. | ✅ Mouser | ⚠️ Limited | ✅ Mouser | ✅ Mouser |
| Documentation | ✅ Comprehensive | ✅ Good | ✅ Good | ✅ Good |
| Price (est.) | ~$20 | ~$40 | ~$25 (SiP) | ~$25 |

## Recommendation

The **MYiR MYC-YF13X** (STM32MP135) is the current sweet spot for this project:

- **Availability**: Both the SOM and the MYD-YF13X DevKit are readily available at Mouser in single quantities — no MOQ, no direct-from-China-only ordering required.
- **Documentation**: Surprisingly comprehensive for a Chinese SOM vendor. MYiR provides full schematics, Gerber files, datasheets, user manuals (EN/CN), and a complete Yocto BSP (kernel, U-Boot, TF-A, OP-TEE, root filesystem).
- **BSP quality**: The Yocto BSP has not been fully evaluated yet — build quality, patch currency, and long-term maintainability still need to be tested.
- **Price**: At ~$20 per SOM, it significantly undercuts Variscite and Phytec alternatives.
- **Dual GbE**: Two Gigabit Ethernet MACs built into the STM32MP135 — no external switch or USB-Ethernet adapter needed.

### Notable alternatives

- **Phytec phyCORE-AM335x**: Best-in-class documentation and long-term availability (15+ years guaranteed), but only available direct from Phytec (no Mouser/DigiKey). Higher price point. A good option if supply chain predictability is paramount.
- **Digi ConnectCore**: Modules are well-stocked at Mouser, but the documentation is fragmented and difficult to work with — a significant drawback for rapid prototyping.
- **Octavo OSD335x**: Available at Mouser, good community support (BeagleBone ecosystem), dual GbE via PRU-ICSS. A solid fallback if MYiR's BSP quality turns out to be insufficient.

For a future redesign targeting higher throughput, consider SOMs with more powerful processors (e.g., TI AM62x-based modules or NXP i.MX8M Mini SOMs with dual GbE via switch IC).
