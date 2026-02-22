# WireGuard Configuration Templates

This directory contains WireGuard configuration templates for the Integrated
Micro Firewall.

## Files

| File | Description |
|------|-------------|
| `wg0-server.conf.template` | IMF (server / responder) configuration |
| `wg0-client.conf.template` | Administrator workstation (client / initiator) configuration |

## Quick Start

### On the IMF

1. Generate a key pair:

   ```bash
   wg genkey | tee /etc/wireguard/privatekey | wg pubkey > /etc/wireguard/publickey
   chmod 600 /etc/wireguard/privatekey
   ```

2. Copy and customise the server template:

   ```bash
   cp wg0-server.conf.template /etc/wireguard/wg0.conf
   chmod 600 /etc/wireguard/wg0.conf
   # Edit /etc/wireguard/wg0.conf – replace <IMF_PRIVATE_KEY> and <ADMIN_PUBLIC_KEY>
   ```

3. Enable the interface:

   ```bash
   systemctl enable --now wg-quick@wg0
   ```

### On the Administrator Workstation

1. Generate a key pair:

   ```bash
   wg genkey | tee privatekey | wg pubkey > publickey
   chmod 600 privatekey
   ```

2. Copy and customise the client template:

   ```bash
   cp wg0-client.conf.template wg0.conf
   # Edit wg0.conf – replace <ADMIN_PRIVATE_KEY>, <IMF_PUBLIC_KEY>, <IMF_PUBLIC_IP>
   ```

3. Start the connection (Linux):

   ```bash
   sudo wg-quick up ./wg0.conf
   ```

## Related Documents

- [Use Case: HP iLO Protection](../../../docs/use-cases/hp-ilo-protection.md)
- [Software Overview](../../../docs/software/software-overview.md)
