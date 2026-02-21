# meta-imf – Integrated Micro Firewall Yocto Layer

This is the custom Yocto layer for the Integrated Micro Firewall project. It is
layered on top of the MYiR BSP (`meta-myir`) and provides:

- **`imf` distro** – minimal, security-hardened distribution configuration
- **`imf-image`** – the target root filesystem image
- **Firewall recipes** – nftables rule set provisioning
- **WireGuard recipes** – WireGuard kernel module + tools (if not already in
  `meta-networking`)

## Layer Dependencies

| Layer | Branch | Source |
|-------|--------|--------|
| `meta` | kirkstone | Yocto poky |
| `meta-oe` | kirkstone | meta-openembedded |
| `meta-networking` | kirkstone | meta-openembedded |
| `meta-myir` | kirkstone | MYiR GitHub |

## Usage

See [Yocto Build Guide](../../docs/software/yocto-build.md) for full setup instructions.

Add `meta-imf` to your `bblayers.conf`:

```bitbake
BBLAYERS += "${TOPDIR}/../sources/meta-imf"
```

Set the machine and distro in `local.conf`:

```bitbake
MACHINE = "myc-yf13x"
DISTRO  = "imf"
```

Build the image:

```bash
bitbake imf-image
```
