#!/usr/bin/env bash
# Post-create setup for the IMF Yocto devcontainer
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=== IMF Devcontainer Post-Create Setup ==="

# Ensure yocto-bsp/build directory exists
mkdir -p "${WORKSPACE_DIR}/yocto-bsp/build"

# If the BSP layers haven't been extracted yet, show instructions
if [ ! -d "${WORKSPACE_DIR}/yocto-bsp/layers/openembedded-core" ]; then
    echo ""
    echo "⚠  Yocto BSP layers not found at yocto-bsp/layers/"
    echo "   Extract the BSP tarball first:"
    echo ""
    echo "   tar xjf .release-staging/yf13x-yocto-stm32mp1-5.15.67.tar.bz2 -C yocto-bsp/"
    echo ""
    echo "   Or fetch from GHCR:"
    echo "   ./scripts/fetch-vendor-bsp.sh"
    echo ""
fi

# If layers exist, show how to start the build
if [ -d "${WORKSPACE_DIR}/yocto-bsp/layers/openembedded-core" ]; then
    echo ""
    echo "✓  BSP layers found. To start a build:"
    echo ""
    echo "   source yocto-bsp/layers/openembedded-core/oe-init-build-env yocto-bsp/build"
    echo "   MACHINE=myd-yf13x bitbake myir-image-core"
    echo ""
fi

echo "=== Setup complete ==="
