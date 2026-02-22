# Integrated Micro Firewall – Copilot Custom Instructions

## Project Overview

- **Hardware**: STM32MP1-based PCI firewall (MYiR MYC-YF13X SOM), KiCad PCB design
- **Software**: Yocto-based embedded Linux, nftables firewall, WireGuard VPN
- **Goal**: Transparent network firewall as a PCI plug-in card (e.g., for protecting HP iLO)

## Repo Structure

```
hardware/       → KiCad PCB + vendor reference data (datasheets, Gerber)
software/       → Yocto layer (meta-imf), configuration, vendor BSP instructions
scripts/        → Build, fetch, and cleanup scripts
docs/           → Architecture, hardware, and software documentation
```

## Conventions

- Vendor BSP binaries are **not** stored in Git; they are hosted in GHCR as OCI artifacts
- Download via `scripts/fetch-vendor-bsp.sh` (requires `oras` CLI)
- Custom development and vendor data are strictly separated (`vendor/` subdirectories)
- `.gitignore` excludes build outputs, tarballs, and KiCad backups

## Detailed Skills

For task-specific instructions, see the skills in `.github/skills/`:

- **`ghcr-oci-artifacts`** – Manage large binaries via oras CLI in GHCR
- **`cjk-filename-renaming`** – Rename Chinese filenames from vendor deliverables
- **`embedded-git-hygiene`** – Repo structure and .gitignore for Yocto/KiCad projects
