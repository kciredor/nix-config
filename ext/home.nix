# Almost on-par with NixOS. TODO:
# - Expand i3status-rust blocks or replace with Polybar.
# - Fonts do not apply (i3status-rust, tmux, vim, etc.).
# - Perhaps more from nixos/configuration to linux.sh.
# - Ghidra and Binary Ninja including symlinks.sh.

{ config, pkgs, lib, ... }:

lib.mkMerge [
  (import /home/kciredor/ops/nix-config/shared/home.nix { config = config; pkgs = pkgs; lib = lib; }).home
  (import /home/kciredor/ops/nix-config/shared/linux.nix { config = config; pkgs = pkgs; lib = lib; }).linux
  (import /home/kciredor/ops/nix-config/shared/desktop.nix { config = config; pkgs = pkgs; lib = lib; }).desktop
  {
    programs.home-manager.enable = true;
    nixpkgs.config.allowUnfree = true;
    news.display = "silent";

    home = {
      stateVersion = "22.11";

      username = "kciredor";
      homeDirectory = "/home/kciredor";

      keyboard = {
        layout = "dvorak";
        options = [
          "caps:swapescape"
        ];
      };

      sessionVariables = {
        PATH = "/home/kciredor/.nix-profile/bin:${builtins.getEnv "PATH"}";
      };

      shellAliases = {
        vinix   = "vim ~/ops/nix-config/ext/home.nix ~/ops/nix-config/shared/home.nix ~/ops/nix-config/shared/linux.nix ~/ops/nix-config/shared/desktop.nix";
        rebuild = "nix-channel --update && home-manager switch";

        clip = "xsel -b";

      };
    };

    # NOTE: Alacritty requires OpenGL which is not always supported, for instance when using a work provided VDI.
    xsession.windowManager.i3.config.terminal = "x-terminal-emulator";

    # XXX: Stable (NixOS) and unstable (other Linux) i3status-rust versions have different blocks config syntax.
    programs.i3status-rust.bars = lib.mkForce {
      top = {
        blocks = [
          {
            block = "load";
            interval = 1;
            format = "$1m.eng(w:3)";
          }
          {
            block = "time";
            interval = 60;
            format = "$timestamp.datetime(f:'%a %d/%m %R')";
          }
        ];
        theme = "gruvbox-dark";
        icons = "awesome5";
      };
    };
  }
]
