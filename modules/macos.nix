{ pkgs, config, ... }: {
  imports = [
    ./zed.nix
  ];

  home.packages = with pkgs; [
    m-cli
  ];

  home.shellAliases = {
    clip = "pbcopy";
  };

  programs.zsh.initContent = ''
    export PATH="$PATH:/opt/homebrew/bin"
  '';

  programs.alacritty = {
    enable = true;

    package = null;  # Installed by Homebrew in modules/macos.nix making 'full disk access' permissions stick.

    settings = {
      font.size = 12;
      font.normal.family = "Hack Nerd Font";

      window = {
        opacity = 0.9;
        startup_mode = "Maximized";
        decorations = "None";
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

  programs.aerospace = {
    enable = true;

    launchd = {
      enable = true;
      keepAlive = true;
    };

    settings = {
      config-version = 2;

      start-at-login = false;
      after-startup-command = [];

      key-mapping = {
        preset = "dvorak";
      };

      persistent-workspaces = ["1" "2" "3" "4" "5" "6" "7" "8" "9"];
      on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];

      workspace-to-monitor-force-assignment = {
        "1" = "main";
        "2" = "main";
        "3" = "main";
        "4" = "main";
        "5" = "main";
        "6" = ["secondary" "main"];
        "7" = ["secondary" "main"];
        "8" = ["secondary" "main"];
        "9" = ["secondary" "main"];
      };

      gaps = {
        inner.horizontal = 8;
        inner.vertical = 8;
        outer.left = 6;
        outer.bottom = 6;
        outer.top = 4;
        outer.right = 6;
      };

      mode.main.binding = {
        alt-space = "layout floating tiling";
        alt-f = "fullscreen";
        alt-t = "focus-back-and-forth";
        alt-shift-t = "swap --wrap-around right";
        alt-o = "move-node-to-monitor --wrap-around next";
        alt-h = "workspace prev";
        alt-l = "workspace next";

        alt-enter = "exec-and-forget open -a /Applications/Alacritty.app";

        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";
        alt-6 = "workspace 6";
        alt-7 = "workspace 7";
        alt-8 = "workspace 8";
        alt-9 = "workspace 9";

        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";
        alt-shift-5 = "move-node-to-workspace 5";
        alt-shift-6 = "move-node-to-workspace 6";
        alt-shift-7 = "move-node-to-workspace 7";
        alt-shift-8 = "move-node-to-workspace 8";
        alt-shift-9 = "move-node-to-workspace 9";
      };

      on-window-detected = [
        {
          "if".app-id = "com.apple.finder";
          run = "layout floating";
        }
      ];
    };
  };

  services.jankyborders = {
    enable = true;

    settings = {
      width = 5.0;
      active_color = "0xffeaeaea";
      inactive_color = "0xff5a5a5a";
    };
  };
}
