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
    rebuild = "darwin-rebuild switch --flake $HOME/ops/nix-config#macos && home-manager switch -b backup --flake $HOME/ops/nix-config#kciredor@rs-mbp14";
    vinix   = "vim ~/ops/nix-config/flake.nix ~/ops/nix-config/hosts/kciredor-rs-mbp14.nix ~/ops/nix-config/hosts/macos.nix ~/ops/nix-config/modules/macos.nix ~/ops/nix-config/modules/home.nix ~/ops/nix-config/modules/macos.nix";
  };

  programs.git = {
    userName = "Roderick Schaefer";
    userEmail = "roderick@kciredor.com";
  };

  programs.zsh.history.path = lib.mkForce "$HOME/.HOME/dotfiles/zsh_history";

  programs.zsh.initExtra = ''
    export SSH_AUTH_SOCK=~/.ssh/agent.sock
    ssh-add -l >/dev/null 2>&1 || (ssh-agent -a "$SSH_AUTH_SOCK" >/dev/null; ssh-add ~/.ssh/id_ed25519 >/dev/null 2>&1)
  '';
}
