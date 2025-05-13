{ pkgs, lib, ... }: {
  home.shellAliases = {
    clip = "xsel -b";
  };

  home.packages = with pkgs; [
    libnotify
    xsel  # Required by tmux-yank.
    feh
    scrot

    google-chrome
    vscode
  ];

  home.activation = {
    destop = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD /bin/bash -c 'if [[ ! -e /usr/share/xsessions/home-manager.desktop ]]; then echo -e "[Desktop Entry]\nName=Xsession\nExec=/etc/X11/Xsession\nX-GDM-SessionRegisters=true" | /usr/bin/sudo /bin/tee /usr/share/xsessions/home-manager.desktop >/dev/null; fi'

      $DRY_RUN_CMD /bin/bash -c '/usr/bin/sudo /bin/sed -i "s/XKBOPTIONS=\"\"/XKBOPTIONS=\"caps:swapescape\"/" /etc/default/keyboard'
    '';
  };

  xsession = {
    enable = true;

    windowManager.i3 = rec {
      enable = true;

      config = {
        modifier = "Mod4";
        defaultWorkspace = "workspace number 1";

        gaps = {
          inner = 8;
        };

        window.titlebar = false;
        floating.titlebar = false;

        keybindings = pkgs.lib.mkOptionDefault {
          "${config.modifier}+Shift+e" = "exec i3-nagbar -t warning -m 'Confirm exit?' -b 'Yes' 'i3-msg exit'";

          "${config.modifier}+h" = "exec i3 workspace previous";
          "${config.modifier}+l" = "exec i3 workspace next";
          "${config.modifier}+t" = "focus next";
          "${config.modifier}+o" = "move window to output right";
          "${config.modifier}+Shift+o" = "move workspace to output right";
          "${config.modifier}+Shift+t" = "move right";
        };

        bars = [{
          position  = "top";
          fonts.size = 10.0;
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs $HOME/.config/i3status-rust/config-top.toml";
        }];
      };
    };
  };

  programs.i3status-rust = {
    enable = true;

    bars = {
      top = {
        blocks = [
          {
            block = "load";
            interval = 1;
            format = "$1m.eng(w:3)";
          }
          {
            block = "battery";
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
  };

  programs.alacritty = {
    enable = true;

    settings = {
      font.size = 12;

      window = {
        opacity = 0.9;
        startup_mode = "Maximized";
        decorations = "None";
      };

      env = {
        # Required by multi monitor setup with different DPI.
        WINIT_X11_SCALE_FACTOR = "1";
      };
    };
  };

  # Nix and GL don't play well together. Prioritize OS package manager install of Alacritty over Nixpkgs.
  programs.zsh.initContent = "alias alacritty='/usr/bin/alacritty || alacritty'";
}
