kciredor's NixOS configuration.
===============================

_Work in progress on a VM. Switching to NixOS as my daily OS soon._

Boot from NixOS minimal install and ensure you have an internet connection.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/kciredor/nixos-config/master/bootstrap.sh)"
```

Post install:
- Networkmanager wifi profiles need to be added.
- Firefox installed extensions need to be enabled and sync turned on.
- Dropbox requires a reboot after first install and running `dropbox status` to get a login link.
