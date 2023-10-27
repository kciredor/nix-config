# MacOS with home-manager for user kciredor, MacOS system is provisioned separately.
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
    ../modules/macos.nix
    ../modules/mail.nix
  ];

  home = {
    username = "kciredor";
    homeDirectory = "/Users/kciredor";
    stateVersion = "23.05";
  };

  home.shellAliases = {
    rebuild = "darwin-rebuild switch --flake $HOME/ops/nix-config#macos && home-manager switch -b backup --flake $HOME/ops/nix-config#$USER@(hostname)";
    vinix   = "vim ~/ops/nix-config/flake.nix ~/ops/nix-config/hosts/kciredor-rs-mbp14.nix ~/ops/nix-config/hosts/macos.nix ~/ops/nix-config/modules/macos.nix ~/ops/nix-config/modules/home.nix ~/ops/nix-config/modules/macos.nix";
  };

  programs.git = {
    userName = "Roderick Schaefer";
    userEmail = "roderick@wehandle.it";
  };
}
