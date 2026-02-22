#!/usr/bin/env bash
# =============================================================================
# push-vendor-bsp-oci.sh
#
# Pushes all vendor BSP files from .release-staging/ to GHCR as OCI artifacts.
# Usage: ./scripts/push-vendor-bsp-oci.sh
# =============================================================================
set -euo pipefail

REPO_OWNER="the78mole"
REPO_NAME="integrated-micro-firewall"
REGISTRY="ghcr.io/${REPO_OWNER}/${REPO_NAME}"
TAG="1.0"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STAGING_DIR="$(cd "$SCRIPT_DIR/../.release-staging" && pwd)"

if [[ ! -d "$STAGING_DIR" ]]; then
    echo "ERROR: .release-staging/ not found. Nothing to push."
    exit 1
fi

echo "============================================"
echo "Pushing vendor BSP files to GHCR as OCI"
echo "Registry: ${REGISTRY}"
echo "Tag:      ${TAG}"
echo "============================================"
echo ""

# Push each file as its own OCI artifact
for filepath in "$STAGING_DIR"/*; do
    filename="$(basename "$filepath")"

    # Derive a package name from the filename (lowercase, no dots except extension)
    pkg_name="$(echo "$filename" | tr '[:upper:]' '[:lower:]' | sed 's/\.tar\.\(bz2\|xz\|gz\|zst\)$//' | sed 's/\.rar$//' | sed 's/\.zip$//')"
    # Replace dots and underscores with dashes for OCI naming
    pkg_name="$(echo "$pkg_name" | tr '._' '--')"

    ref="${REGISTRY}/vendor-bsp/${pkg_name}:${TAG}"

    echo "PUSH: $filename"
    echo "  -> $ref"
    echo "  Size: $(du -sh "$filepath" | cut -f1)"

    # oras needs relative paths — push from the staging directory
    (cd "$STAGING_DIR" && oras push "$ref" \
        --artifact-type "application/vnd.imf.vendor-bsp" \
        "${filename}:application/octet-stream")

    echo "  OK"
    echo ""
done

echo "============================================"
echo "All files pushed. Verify with:"
echo "  gh api /user/packages?package_type=container | jq '.[].name'"
echo "============================================"
