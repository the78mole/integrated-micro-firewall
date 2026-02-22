# MYiR Technology — Vendor Reference Data

## About MYiR

[MYiR Technology](https://www.myirtech.com/) is a Chinese embedded systems company based in Shenzhen, specializing in ARM-based System-on-Modules (SOMs) and development kits. They offer modules based on NXP i.MX, TI Sitara, ST STM32MP, and other processors.

MYiR provides complete BSPs (Board Support Packages) for their modules, typically based on Yocto or Buildroot, including kernel, bootloader, and root filesystem.

## Module Used in This Project

| Parameter | Value |
|-----------|-------|
| SOM | MYC-YF13X |
| DevKit | MYD-YF13X |
| Processor | STM32MP135 (Cortex-A7 @ 1 GHz) |
| RAM | 256 MB DDR3L |
| Flash | 256 MB NAND / 4 GB eMMC |
| Ethernet | 2× Gigabit Ethernet |

## Downloads

All vendor files (BSP, tools, hardware reference, manuals) are available at:

**<https://d.myirtech.com/MYD-YF13X/>**

This includes:

- **BSP**: Yocto-based Linux BSP (kernel, U-Boot, TF-A, OP-TEE, root filesystem)
- **Tools**: Flash tools, QT SDK
- **Hardware files**: Schematics, Gerber files, PCB source (Allegro)
- **User manuals**: English and Chinese

> **Note**: The large BSP tarballs (~15 GB total) are not stored in this Git repository.
> They are hosted as OCI artifacts in GHCR and can be downloaded via
> `scripts/fetch-vendor-bsp.sh`. See [software/vendor/README.md](../../../software/vendor/README.md) for details.

## Sourcing

| Channel | Availability |
|---------|-------------|
| [Mouser](https://www.mouser.com/) | ✅ SOM and DevKit in stock (single units) |
| [MYiR Direct](https://www.myirtech.com/) | ✅ Direct ordering from Shenzhen |
| AliExpress | ⚠️ Occasionally available |

## Directory Contents

```
myir/
├── README.md           ← This file
├── datasheets/         ← IC and module datasheets
├── hardware-files/     ← Schematics, Gerber, PCB source (Allegro .brd)
├── manuals/            ← User manuals (EN/CN)
└── tools/              ← Flash tools, QT SDK
```
