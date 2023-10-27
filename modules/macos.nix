{ pkgs, lib, config, ... }: {
  home.packages = with pkgs; [
    m-cli
  ];

  home.shellAliases = {
    clip = "pbcopy";
  };

  home.file.".gnupg/gpg-agent.conf".text = ''
    enable-ssh-support
    pinentry-program /opt/homebrew/bin/pinentry-mac
  '';

  programs.fish.shellInit = ''
    set -xg PATH "$PATH:/opt/homebrew/bin"
    set -xg SSH_AUTH_SOCK $HOME/.gnupg/S.gpg-agent.ssh
    /usr/bin/pgrep gpg-agent >/dev/null || gpg-agent --daemon >/dev/null
  '';

  programs.alacritty = {
    enable = true;

    settings = {
      font.size = 12;
      font.normal.family = "Hack Nerd Font";

      window = {
        opacity = 0.9;
        startup_mode = "Maximized";
      };

      shell = {
        program = "${pkgs.tmux}/bin/tmux";
        args = [
          "new"
          "-As"
          "main"
        ];
      };

      env = {
        PATH = "${config.home.homeDirectory}/.nix-profile/bin";
      };
    };
  };
}
