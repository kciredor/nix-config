kciredor's Nix configuration for NixOS and MacOS
================================================

# NixOS

## Install
Boot from NixOS minimal install and ensure you have an internet connection.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/kciredor/nix-config/master/nixos/bootstrap.sh)"
```

## First boot
- Look into ./secrets/<youruser> (see exampleuser) and trigger a rebuild if needed.

## Next steps
- Networkmanager wifi profiles.
- Dropbox login link via `dropbox status`.
- Goobook login with `goobook authenticate`.
- Etc.
