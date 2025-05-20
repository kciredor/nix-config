{ pkgs, lib, config, ... }: {
  home.packages = with pkgs; [
    m-cli
  ];

  home.shellAliases = {
    clip = "pbcopy";
  };

  programs.zsh.initContent = ''
    export PATH="$PATH:/opt/homebrew/bin"
  '';

  # TODO: Replace with Ghostty, see: https://github.com/NixOS/nixpkgs/issues/388984.
  programs.alacritty = {
    enable = true;

    settings = {
      font.size = 12;
      font.normal.family = "Hack Nerd Font";

      window = {
        opacity = 0.9;
        startup_mode = "Maximized";
        option_as_alt = "OnlyLeft";
      };

      terminal.shell = {
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
