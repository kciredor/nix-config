kciredor's NixOS configuration.
===============================

# Install
Boot from NixOS minimal install and ensure you have an internet connection.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/kciredor/nixos-config/master/bootstrap.sh)"
```

# First boot
- Look into ./nixos/secrets/<youruser> (see exampleuser) and trigger a rebuild if needed.

# Next steps
- Networkmanager wifi profiles.
- Dropbox login link via `dropbox status`.
- Firefox installed extensions need to be enabled and sync turned on.
- Etc.
