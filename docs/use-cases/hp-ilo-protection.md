# Use Case: HP iLO Protection

## Overview

HP iLO (Integrated Lights-Out) is a server management interface that provides
out-of-band access to the server hardware. It typically listens on a dedicated
Ethernet port and exposes a web interface (HTTPS) and SSH. When a server is
co-located in an external data centre, the iLO port may be directly reachable
from the internet, which poses a significant security risk.

The Integrated Micro Firewall (IMF) is placed between the iLO port and the
external network to enforce strict access control.

## Network Topology

```
                    ┌─────────────────────────────────────────┐
                    │           Host Server                   │
                    │                                         │
  External Network  │  ┌──────────────────────────────────┐  │
  (Data Centre)     │  │    Integrated Micro Firewall     │  │
      │             │  │         (IMF / PCIe Card)        │  │
      │             │  │                                  │  │
      ├─── ETH1 ────┼──┤►  nftables + WireGuard server   │  │
      │             │  │                                  │  │
      │             │  └─────────────┬────────────────────┘  │
      │             │                │ ETH0                   │
      │             │  ┌─────────────▼──────────────────┐    │
      │             │  │          HP iLO Port           │    │
      │             │  │   (HTTPS :443, SSH :22)        │    │
      │             │  └────────────────────────────────┘    │
      │             └─────────────────────────────────────────┘
      │
  ┌───┴───────────────────┐
  │  Remote Administrator │
  │  (WireGuard client)   │
  └───────────────────────┘
```

## Traffic Flow

| Source | Destination | Protocol | Action | Note |
|--------|-------------|----------|--------|------|
| Internet | IMF ETH1 | UDP/51820 | ACCEPT | WireGuard handshake & tunnel |
| Internet | IMF ETH1 | any other | DROP | Default deny |
| WireGuard peer | iLO ETH0 | TCP/443 | FORWARD | iLO web UI |
| WireGuard peer | iLO ETH0 | TCP/22 | FORWARD | iLO SSH |
| iLO ETH0 | WireGuard peer | established | FORWARD | Return traffic (stateful) |
| iLO ETH0 | Internet | any | DROP | iLO must not initiate outbound |

## nftables Rule Set

The following rule set is deployed on the IMF. It is maintained at
[`software/config/firewall/nftables.conf`](../../software/config/firewall/nftables.conf).

```nftables
#!/usr/sbin/nft -f

flush ruleset

define ETH_EXT  = eth1       # External / uplink interface
define ETH_MGMT = eth0       # Management / iLO interface
define WG_IF    = wg0        # WireGuard tunnel interface
define WG_PORT  = 51820      # WireGuard UDP listen port
define ILO_HTTPS = 443       # HP iLO web UI
define ILO_SSH   = 22        # HP iLO SSH

table inet filter {

    chain input {
        type filter hook input priority filter; policy drop;

        # Allow established / related
        ct state { established, related } accept

        # Loopback
        iifname lo accept

        # ICMP (ping) – rate-limited
        ip  protocol icmp   icmp  type echo-request limit rate 5/second accept
        ip6 nexthdr  icmpv6 icmpv6 type echo-request limit rate 5/second accept

        # WireGuard incoming on external interface
        iifname $ETH_EXT udp dport $WG_PORT accept

        # SSH to IMF management plane – only from WireGuard tunnel
        iifname $WG_IF tcp dport 22 accept
    }

    chain forward {
        type filter hook forward priority filter; policy drop;

        # Allow established / related
        ct state { established, related } accept

        # WireGuard peer → iLO management interface
        iifname $WG_IF  oifname $ETH_MGMT tcp dport { $ILO_HTTPS, $ILO_SSH } accept

        # iLO → WireGuard peer (return traffic handled by ct state above)
    }

    chain output {
        type filter hook output priority filter; policy accept;
    }
}
```

## WireGuard Configuration

### IMF (Server Side)

File location: `/etc/wireguard/wg0.conf` on the IMF (template at
[`software/config/wireguard/wg0-server.conf.template`](../../software/config/wireguard/wg0-server.conf.template)).

```ini
[Interface]
Address    = 10.200.0.1/24
ListenPort = 51820
PrivateKey = <IMF_PRIVATE_KEY>

# Remote administrator workstation
[Peer]
PublicKey  = <ADMIN_PUBLIC_KEY>
AllowedIPs = 10.200.0.2/32
```

### Administrator Workstation (Client Side)

```ini
[Interface]
Address    = 10.200.0.2/24
PrivateKey = <ADMIN_PRIVATE_KEY>
DNS        = 10.200.0.1

[Peer]
PublicKey  = <IMF_PUBLIC_KEY>
Endpoint   = <IMF_PUBLIC_IP>:51820
AllowedIPs = 10.200.0.0/24, 192.168.100.0/24
PersistentKeepalive = 25
```

## Initial Setup Procedure

1. **Generate WireGuard key pair on the IMF:**

   ```bash
   wg genkey | tee /etc/wireguard/privatekey | wg pubkey > /etc/wireguard/publickey
   chmod 600 /etc/wireguard/privatekey
   ```

2. **Exchange public keys** between IMF and administrator workstation.

3. **Edit `/etc/wireguard/wg0.conf`** with the correct keys and peer IP.

4. **Enable the WireGuard interface:**

   ```bash
   systemctl enable --now wg-quick@wg0
   ```

5. **Verify connectivity:**

   ```bash
   # On the administrator workstation
   ping 10.200.0.1          # IMF WireGuard address
   ping 192.168.100.1       # HP iLO IP (example)
   ```

6. **Access HP iLO** via browser: `https://192.168.100.1`

## Security Recommendations

- Rotate WireGuard keys periodically (at least annually).
- Limit the number of enrolled WireGuard peers to the minimum required.
- Use strong, randomly-generated pre-shared keys (`wg genpsk`) for each peer.
- Restrict SSH access to the IMF management plane to specific WireGuard peer addresses.
- Monitor the IMF syslog for unexpected connection attempts.
- Keep the Yocto image up to date with security patches.

## Related Documents

- [System Architecture](../architecture/system-overview.md)
- [Software Overview](../software/software-overview.md)
- [Hardware Overview](../hardware/hardware-overview.md)
