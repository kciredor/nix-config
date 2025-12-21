# Cloudtop VM with home-manager for user kciredor.
{ lib, pkgs, ... }: {
  imports = [
    ../modules/home.nix
    ../modules/linux.nix
  ];

  home = {
    username = "kciredor";
    homeDirectory = "/usr/local/google/home/kciredor";
    stateVersion = "23.05";
  };

  home.shellAliases = {
    rebuild = "home-manager switch -b backup --flake $HOME/nix-config#kciredor@cloudtop";
    vinix   = "vim ~/nix-config/flake.nix ~/nix-config/hosts/kciredor-cloudtop.nix ~/nix-config/modules/home.nix ~/nix-config/modules/linux.nix";
  };

  programs.git = {
    settings = {
      user = {
        name = "Roderick Schaefer";
        email = "kciredor@google.com";
      };
    };
  };

  systemd.user.startServices = lib.mkForce "suggest";
  programs.tmux.shell = "${pkgs.zsh}/bin/zsh";
  programs.bash.initExtra = "export SHELL=${pkgs.zsh}/bin/zsh; tmux attach -t kciredor || tmux new -s kciredor";
}
