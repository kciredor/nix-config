# TODO:
# - Desktop.
# - System (non-home) config.

{ config, pkgs, lib, ... }:

lib.mkMerge [
  (import /home/kciredor/ops/nix-config/shared/home.nix { config = config; pkgs = pkgs; lib = lib; }).kciredor
  {
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

      activation.userscripts = lib.mkForce "";
    };

    programs.home-manager.enable = true;

    programs.fish.shellInit = ''
      set -xg PATH "/home/kciredor/.nix-profile/bin:$PATH"
    '';
  }
]
