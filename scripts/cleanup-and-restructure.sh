#!/usr/bin/env bash
# =============================================================================
# cleanup-and-restructure.sh
#
# Macht das integrated-micro-firewall Repo "Git-ready":
#   1. Redundante ZIPs löschen (entpackte Daten existieren bereits)
#   2. Große BSP-Tarballs in ein separates Verzeichnis verschieben
#      (für Upload als GitHub Release, NICHT ins Git)
#   3. Verzeichnisstruktur bereinigen
#
# ACHTUNG: Vor dem Ausführen ein Backup machen!
#   cp -a integrated-micro-firewall integrated-micro-firewall.bak
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

# Staging area for files to upload to GitHub Releases
RELEASE_STAGING="$REPO_ROOT/.release-staging"
mkdir -p "$RELEASE_STAGING"

echo "========================================="
echo "Phase 1: Redundante ZIPs löschen"
echo "========================================="

# Diese ZIPs sind identisch mit bereits entpackten Verzeichnissen
REDUNDANT_ZIPS=(
    "hardware/INFO/MYIR/BSP.zip"
    "hardware/INFO/MYIR/03_Tools.zip"
    "hardware/INFO/MYIR/Hardwarefiles.zip"
    "hardware/INFO/MYIR/UserManual.zip"
    "hardware/INFO/MYIR/HardwareFiles/MYB-YF13X-V10-PCB-xxx-20230424.zip"
    "hardware/INFO/MYIR/HardwareFiles/MYB-YF13X-V10-PCB/Gerber/MYB-YF13X-V10-Gerber.zip"
)

for f in "${REDUNDANT_ZIPS[@]}"; do
    if [[ -f "$f" ]]; then
        echo "  LÖSCHEN (redundant): $f ($(du -sh "$f" | cut -f1))"
        rm -f "$f"
    else
        echo "  SKIP (nicht gefunden): $f"
    fi
done

echo ""
echo "========================================="
echo "Phase 2: Große Binärdateien → Release-Staging"
echo "========================================="

# Diese Tarballs sollen als GitHub Release hochgeladen werden
LARGE_BINARIES=(
    "software/BSP/Yocto-qt-downloads.tar.xz"
    "software/BSP/Kernel/MYiR-STM32-kernel.tar.bz2"
    "software/BSP/Bootloader/MYiR-STM32-u-boot.tar.bz2"
    "software/BSP/yf13x-yocto-stm32mp1-5.15.67.tar.bz2"
    "software/BSP/Tf-a/MYiR-STM32-tf-a.tar.bz2"
    "software/BSP/Optee/MYiR-STM32-optee.tar.bz2"
    "software/BSP/mxapp2.tar.gz"
    "hardware/INFO/MYIR/03_Tools/QT-SDK/sdk-qt.tar.xz"
    "hardware/INFO/MYIR/myc-yf13x-STEP.rar"
)

for f in "${LARGE_BINARIES[@]}"; do
    if [[ -f "$f" ]]; then
        echo "  VERSCHIEBEN: $f ($(du -sh "$f" | cut -f1)) → .release-staging/"
        mv "$f" "$RELEASE_STAGING/"
    else
        echo "  SKIP (nicht gefunden): $f"
    fi
done

echo ""
echo "========================================="
echo "Phase 3: Verzeichnisstruktur bereinigen"
echo "========================================="

# --- KiCad-Dateien: hardware/ root → hardware/kicad/ ---
echo "  KiCad-Dateien → hardware/kicad/"
mkdir -p hardware/kicad
for ext in kicad_pcb kicad_prl kicad_pro kicad_sch; do
    for f in hardware/PCI-Firewall.$ext; do
        [[ -f "$f" ]] && mv "$f" hardware/kicad/
    done
done

# --- Hersteller-Hardware-Daten → hardware/vendor/myir/ ---
echo "  Hersteller-Daten → hardware/vendor/myir/"
mkdir -p hardware/vendor/myir

# Datasheets
if [[ -d "hardware/DATASHEETS" ]]; then
    mv hardware/DATASHEETS hardware/vendor/myir/datasheets
fi

# Hardware-Files (PCB, Gerber, SMT)
if [[ -d "hardware/INFO/MYIR/HardwareFiles" ]]; then
    mv hardware/INFO/MYIR/HardwareFiles hardware/vendor/myir/hardware-files
fi

# User Manuals
if [[ -d "hardware/INFO/MYIR/UserManual" ]]; then
    mv hardware/INFO/MYIR/UserManual hardware/vendor/myir/manuals
fi

# --- BSP Examples (klein genug für Git) → software/vendor/examples/ ---
echo "  BSP-Beispiele → software/vendor/examples/"
mkdir -p software/vendor
if [[ -d "software/BSP/Example" ]]; then
    mv software/BSP/Example software/vendor/examples
fi

# --- Leere Tools-Verzeichnisse aufräumen ---
echo "  Leere myir-tools → hardware/vendor/myir/tools/"
if [[ -d "hardware/INFO/MYIR/03_Tools/myir-tools" ]]; then
    mkdir -p hardware/vendor/myir/tools
    mv hardware/INFO/MYIR/03_Tools/myir-tools/* hardware/vendor/myir/tools/ 2>/dev/null || true
fi

# --- Alte Verzeichnisse entfernen (wenn leer) ---
echo "  Leere Restverzeichnisse entfernen..."
find hardware/INFO -type d -empty -delete 2>/dev/null || true
rmdir hardware/INFO/MYIR/03_Tools/myir-tools 2>/dev/null || true
rmdir hardware/INFO/MYIR/03_Tools/QT-SDK 2>/dev/null || true
rmdir hardware/INFO/MYIR/03_Tools 2>/dev/null || true
rmdir hardware/INFO/MYIR 2>/dev/null || true
rmdir hardware/INFO 2>/dev/null || true

# BSP-Verzeichnis aufräumen (Tarballs sind weg, nur leere Ordner bleiben)
find software/BSP -type d -empty -delete 2>/dev/null || true
rmdir software/BSP 2>/dev/null || true

# KiCad-Backup-Ordner
rm -rf PCI-Firewall-backups 2>/dev/null || true

echo ""
echo "========================================="
echo "Phase 4: Vendor-README erstellen"
echo "========================================="

# Platzhalter-README für BSP-Downloads
mkdir -p software/vendor
cat > software/vendor/README.md << 'VENDOREOF'
# Vendor BSP Files

The MYiR STM32MP13X BSP tarballs are **not tracked in Git** due to their size (~15 GB).

## Download

Download them from the GitHub Release tagged `vendor-bsp-v1.0`:

```bash
# Or use the helper script:
../scripts/fetch-vendor-bsp.sh
```

### Included files

| File | Size | Description |
|------|------|-------------|
| `Yocto-qt-downloads.tar.xz` | 13 GB | Yocto DL_DIR cache (optional) |
| `MYiR-STM32-kernel.tar.bz2` | 385 MB | Linux kernel source |
| `MYiR-STM32-u-boot.tar.bz2` | 191 MB | U-Boot source |
| `yf13x-yocto-stm32mp1-5.15.67.tar.bz2` | 360 MB | Yocto BSP layer |
| `MYiR-STM32-tf-a.tar.bz2` | 31 MB | TF-A (ARM Trusted Firmware) |
| `MYiR-STM32-optee.tar.bz2` | 22 MB | OP-TEE |
| `mxapp2.tar.gz` | 31 MB | Demo application |
| `sdk-qt.tar.xz` | 1.2 GB | Qt cross-compilation SDK |
VENDOREOF

echo "  ✓ software/vendor/README.md erstellt"

echo ""
echo "========================================="
echo "ZUSAMMENFASSUNG"
echo "========================================="
echo ""
echo "Release-Staging Verzeichnis (zum Upload auf GitHub Releases):"
ls -lhS "$RELEASE_STAGING/" 2>/dev/null || echo "  (leer)"
echo ""
echo "Aktuelle Repo-Größe (ohne .git):"
du -sh --exclude='.git' --exclude='.release-staging' .
echo ""
echo "NÄCHSTE SCHRITTE:"
echo "  1. Prüfe die neue Struktur:  tree -L 3 --dirsfirst"
echo "  2. Erstelle ein GitHub Release und lade .release-staging/* hoch"
echo "  3. git add -A && git commit -m 'chore: restructure repo, remove redundant archives'"
echo "  4. Optional: rm -rf .release-staging/  (nach Upload)"
