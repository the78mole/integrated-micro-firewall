# Firewall Configuration

This directory contains the nftables rule set for the Integrated Micro Firewall.

## Files

| File | Description |
|------|-------------|
| `nftables.conf` | Main nftables rule set (HP iLO protection use case) |

## Deployment

Copy `nftables.conf` to `/etc/nftables.conf` on the IMF and enable the service:

```bash
cp nftables.conf /etc/nftables.conf
systemctl enable --now nftables
```

## Customisation

Edit the variable definitions at the top of `nftables.conf` to match your network:

| Variable | Default | Description |
|----------|---------|-------------|
| `ETH_EXT` | `eth1` | External (uplink) interface name |
| `ETH_MGMT` | `eth0` | Management (iLO-side) interface name |
| `WG_IF` | `wg0` | WireGuard tunnel interface |
| `WG_PORT` | `51820` | WireGuard UDP listen port |
| `ILO_HTTPS` | `443` | HP iLO HTTPS port |
| `ILO_SSH` | `22` | HP iLO SSH port |

## Related Documents

- [Use Case: HP iLO Protection](../../../docs/use-cases/hp-ilo-protection.md)
- [Software Overview](../../../docs/software/software-overview.md)
