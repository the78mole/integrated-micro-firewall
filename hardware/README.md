# Hardware Design Files

This directory contains the hardware design files for the Integrated Micro Firewall
PCIe add-in card.

## Directory Structure

```
hardware/
├── pcb/    # KiCad PCB schematic and layout files
└── bom/    # Bill of materials
```

## Sub-directories

### `pcb/`

KiCad project files for the PCIe carrier board:

| File | Description |
|------|-------------|
| `imf-carrier.kicad_pro` | KiCad project file |
| `imf-carrier.kicad_sch` | Schematic |
| `imf-carrier.kicad_pcb` | PCB layout |
| `imf-carrier.pretty/`   | Footprint library |

### `bom/`

| File | Description |
|------|-------------|
| `bom.csv` | Bill of materials (CSV) |

## Design Notes

- See [Hardware Overview](../docs/hardware/hardware-overview.md) for a full description
  of the hardware design.
- PCB is designed in KiCad (version 7 or later).
