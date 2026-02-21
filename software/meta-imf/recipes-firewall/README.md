# Recipes: Firewall

This directory contains Yocto recipes for provisioning the nftables firewall
rule set onto the IMF image.

## Planned Recipes

| Recipe | Purpose |
|--------|---------|
| `imf-firewall-rules` | Installs `/etc/nftables.conf` and enables the `nftables` systemd service |

## Adding a New Rule Set

1. Create a recipe `recipes-firewall/imf-firewall-rules/imf-firewall-rules_1.0.bb`.
2. Add the `nftables.conf` file as a `SRC_URI` file entry.
3. In `do_install`, copy the file to `${D}${sysconfdir}/nftables.conf`.
4. Add a `FILES:${PN}` entry and a `SYSTEMD_SERVICE:${PN}` entry for
   `nftables.service`.
