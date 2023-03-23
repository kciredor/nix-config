kciredor's Nix configuration for MacOS, NixOS and other Linux distro's.
=======================================================================

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
- Etc.

---

# MacOS

## Install
Clean install MacOS preferably with a case-sensitive and encrypted filesystem and ensure you have an internet connection.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/kciredor/nix-config/master/macos/bootstrap.sh)"
```

## First boot
- Look into ./secrets/<youruser> (see exampleuser) and trigger a rebuild if needed.

## Next steps
- Manual system settings:
  - Keyboard dvorak and do not show in menu bar.
  - Login to Gmail account for calendar/contacts.
  - Add multiple desktops (spaces).
  - Prevent automatic sleeping on power adapter when display off.
  - Keyboard shortcuts: space left/right.
  - Add WireGuard network extension to MacOS Firewall.
- Some casks like Backblaze require manually running the deployed installer.
- Provision WireGuard config.
- Add Alacritty to Full Disk Access.
- Login all apps like Backblaze and Dropbox.
- Manual installs which are not in Nixpkgs/ Homebrew/ AppStore, like Binary Ninja and BurpSuite.
- Goobook login with `goobook authenticate`.
- Etc.

---

# Other Linux

## Install
Boot from a freshly installed Linux distro of choie.

```bash
sudo apt -y install curl git  # Or equivalent based on distro's package mananger.
bash -c "$(curl -fsSL https://raw.githubusercontent.com/kciredor/nix-config/master/ext/bootstrap.sh)"
```

## Next steps
Might require additional manual steps, but mostly identical to NixOS next steps.
