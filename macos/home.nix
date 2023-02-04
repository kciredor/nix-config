{
  imports = [
    <home-manager/nix-darwin>

    ../shared/home.nix
    ./mail.nix
  ];

  home-manager = {
    users.root = { pkgs, lib, ... }: {
      home.stateVersion = "22.11";

      # Enables TouchID for sudo approvals. See: https://github.com/LnL7/nix-darwin/pull/228.
      home.activation = {
        userscripts = lib.hm.dag.entryAfter ["writeBoundary"] ''
          $DRY_RUN_CMD /Users/kciredor/ops/nix-config/scripts/root/macos.sh $VERBOSE_ARG

          $DRY_RUN_CMD grep -q 'pam_tid.so' /etc/pam.d/sudo || ${pkgs.gnused}/bin/sed -i '2i\
          auth       sufficient     pam_tid.so
          ' /etc/pam.d/sudo
          $DRY_RUN_CMD grep -q 'pam_reattach.so' /etc/pam.d/sudo || ${pkgs.gnused}/bin/sed -i '2i\
          auth       optional       pam_reattach.so
          ' /etc/pam.d/sudo
        '';
      };
    };

    users.kciredor = { pkgs, lib, ... }: {
      home.stateVersion = "22.11";

      home.packages = with pkgs; [
        m-cli
      ];

      home.shellAliases = {
        vinix   = "vim ~/ops/nix-config/macos/configuration.nix ~/ops/nix-config/shared/home.nix ~/ops/nix-config/macos/home.nix ~/ops/nix-config/macos/mail.nix ~/ops/nix-config/dotfiles/kciredor/hammerspoon/init.lua";
        rebuild = "nix-channel --update && darwin-rebuild switch";

        clip    = "pbcopy";
      };

      programs.fish.shellInit = ''
        # Overrides Mac shipped coreutils, findutils etc.
        set -xg PATH "/etc/profiles/per-user/kciredor/bin:$PATH"

        set -xg SSH_AUTH_SOCK $HOME/.gnupg/S.gpg-agent.ssh
        pgrep gpg-agent >/dev/null || gpg-agent --daemon >/dev/null
      '';

      programs.alacritty = {
        settings = {
          font.size = lib.mkForce 12;
          font.normal.family = "Hack Nerd Font";

          shell = {
            program = "${pkgs.tmux}/bin/tmux";
            args = [
              "new"
              "-As"
              "kciredor"
            ];
          };

          window = {
            startup_mode = "SimpleFullscreen";
            padding.x = 1;

            dimensions = {
              columns = 200;
              lines = 80;
            };
          };

          env = {
            # Tmux plugins cannot find tmux without this during startup.
            PATH = "/etc/profiles/per-user/kciredor/bin";
          };

          key_bindings = [
            { key = "F"; mods = "Shift|Option"; action = "ToggleSimpleFullscreen"; }
          ];
        };
      };

      programs.tmux = {
        shell = "${pkgs.fish}/bin/fish";

        # Overrules Sensible plugin deprecated MacOS fix which is in our way.
        extraConfig = ''
          set -gu default-command
        '';
      };

      home.file.".gnupg/gpg-agent.conf".text = ''
        enable-ssh-support
        pinentry-program /usr/local/bin/pinentry-mac
      '';
    };
  };
}
