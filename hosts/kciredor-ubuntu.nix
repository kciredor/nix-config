# Ubuntu VM with home-manager for user kciredor and desktop specifics enabled.
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ../modules/home.nix
    ../modules/linux-desktop.nix
  ];

  home = {
    username = "kciredor";
    homeDirectory = "/home/kciredor";
    stateVersion = "23.05";
  };

  home.shellAliases = {
    rebuild = "home-manager switch -b backup --flake $HOME/ops/nix-config#$USER@$(cat /etc/hostname)";
    vinix   = "vim ~/ops/nix-config/flake.nix ~/ops/nix-config/hosts/kciredor-ubuntu.nix ~/ops/nix-config/modules/home.nix ~/ops/nix-config/modules/linux.nix ~/ops/nix-config/modules/desktop.nix";
  };

  programs.git = {
    userName = "Roderick Schaefer";
    userEmail = "roderick@kciredor.com";
  };

  # Alacritty does not work for this virtual host.
  xsession.windowManager.i3.config.terminal = "x-terminal-emulator";
}
