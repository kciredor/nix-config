{ pkgs, lib, config, ... }:

{
  home-manager = {
    users.kciredor = { pkgs, lib, ... }: {
      xsession.windowManager.i3 = rec {
        enable = true;
  
        config = {
          modifier = "Mod4";
          defaultWorkspace = "workspace number 1";
          terminal = "alacritty";
  
          gaps = {
            inner = 8;
          };
  
          keybindings = pkgs.lib.mkOptionDefault {
            # In case of a xfce+i3 session: xfce4-session-logout.
            "${config.modifier}+Shift+e" = "exec i3-nagbar -t warning -m 'Confirm exit?' -b 'Yes' 'i3-msg exit'";
            "${config.modifier}+F10" = "exec autorandr -c";
            "${config.modifier}+F11" = "exec systemctl suspend-then-hibernate";
            "${config.modifier}+F12" = "exec i3lock-color -i ~/.background-image --ring-color=000000 --keyhl-color ffffff";
  
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
  
        extraConfig = ''
          # Volume buttons. Alternatively there is sound.mediaKeys.enable.
          bindsym XF86AudioMute        exec --no-startup-id pactl set-sink-mute   @DEFAULT_SINK@ toggle
          bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%
          bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5%
  
          # Media buttons.
          bindsym XF86AudioPlay exec --no-startup-id ${pkgs.playerctl}/bin/playerctl play-pause
          bindsym XF86AudioNext exec --no-startup-id ${pkgs.playerctl}/bin/playerctl next
          bindsym XF86AudioPrev exec --no-startup-id ${pkgs.playerctl}/bin/playerctl previous
  
          # Screenshots.
          bindsym Print                 exec "scrot -m '%Y%m%d_%H%M%S.png' -e 'mv $f ~/images/screenshots/ ; ${pkgs.libnotify}/bin/notify-send Screenshot $f'"
          bindsym --release Shift+Print exec "scrot -s '%Y%m%d_%H%M%S.png' -e 'mv $f ~/images/screenshots/ ; ${pkgs.libnotify}/bin/notify-send Screenshot $f'"
        '';
      };
  
      programs.i3status-rust = {
        enable = true;
  
        bars = {
          top = {
            blocks = [
              {
                block = "load";
                interval = 1;
                format = "{1m}";
              }
              {
                block = "music";
                player = "cider";
                on_collapsed_click = "cider";
                buttons = [ "play" "next" ];
              }
              {
                block = "custom";
                command = "bash -c 'echo -n \" $(dropbox status)\" | head -n 1'";
              }
              {
                block = "custom";
                command = "journalctl -u borgbackup-job-borgbase.service | grep Deactivated | tail -n 1 | awk '{ print \" \" $1 \" \" $2 }'";
                shell = "bash";
              }
              {
                block = "networkmanager";
                on_click = "alacritty -e nmtui";
                device_format = "{icon}{ap}";
                interface_name_include = [ "eth.*" "wlan.*" "vpn.*" ];
              }
              {
                block = "custom";
                command = "echo ";
                on_click = "bash -c 'blueman-manager; pkill blueman-applet; pkill blueman-tray'";
              }
              {
                block = "sound";
                on_click = "pavucontrol";
              }
              {
                block = "battery";
              }
              {
                block = "time";
                interval = 60;
                format = "%a %d/%m %R";
              }
            ];
            theme = "gruvbox-dark";
            icons = "awesome5";
          };
        };
      };

      # StarBook related, this fixes screen tearing with Intel Iris.
      services.picom = {
        enable = true;
        vSync = true;

        settings = {
          inactive-dim = 0.2;
        };
      };
  
      # Media buttons daemon.
      services.playerctld.enable = true;
  
  
      services.screen-locker = {
        enable = true;
  
        inactiveInterval = 10;
        lockCmd = "${pkgs.i3lock-color}/bin/i3lock-color -i ~/.background-image --ring-color=000000 --keyhl-color ffffff";
      };
  
      # Docking.
      programs.autorandr = {
        enable = true;
  
        hooks.postswitch = {
          "rescale-wallpaper" = "/home/kciredor/.fehbg";
        };
  
        profiles = {
          "laptop" = {
            fingerprint = {
              eDP-1 = "00ffffffffffff000daef21400000000161c0104a51f117802ee95a3544c99260f505400000001010101010101010101010101010101363680a0703820402e1e240035ad10000018000000fe004e3134304843472d4751320a20000000fe00434d4e0a202020202020202020000000fe004e3134304843472d4751320a2000bb";
            };
            config = {
              eDP-1 = {
                enable = true;
                primary = true;
                mode = "1920x1080";
              };
            };
          };
          "home" = {
            fingerprint = {
              eDP-1 = "00ffffffffffff000daef21400000000161c0104a51f117802ee95a3544c99260f505400000001010101010101010101010101010101363680a0703820402e1e240035ad10000018000000fe004e3134304843472d4751320a20000000fe00434d4e0a202020202020202020000000fe004e3134304843472d4751320a2000bb";
              DP-2-8 = "00ffffffffffff0010aca6a04c39413015190104a55021783afd25a2584f9f260d5054a54b00714f81008180a940d1c0010101010101e77c70a0d0a029505020ca041e4f3100001a000000ff0036384d434635354a3041394c0a000000fc0044454c4c205533343135570a20000000fd0030551e5920000a2020202020200173020319f14c9005040302071601141f12132309070783010000023a801871382d40582c25001e4f3100001e584d00b8a1381440942cb5001e4f3100001e9d6770a0d0a0225050205a041e4f3100001a7a3eb85060a02950282068001e4f3100001a565e00a0a0a02950302035001e4f3100001a00000000000000000000000062";
              DP-1 = "00ffffffffffff0010acb8a0534657300f1b0104a53420783a0495a9554d9d26105054a54b00714f8180a940d1c0d100010101010101283c80a070b023403020360006442100001e000000ff00374d543031373444305746530a000000fc0044454c4c2055323431350a2020000000fd00313d1e5311000a202020202020011402031cf14f9005040302071601141f12132021222309070783010000023a801871382d40582c450006442100001e011d8018711c1620582c250006442100009e011d007251d01e206e28550006442100001e8c0ad08a20e02d10103e96000644210000180000000000000000000000000000000000000000000000000000000c";
            };
            config = {
              eDP-1.enable = false;
              DP-2-8 = {
                enable = true;
                primary = true;
                position = "1920x0";
                mode = "3440x1440";
              };
              DP-1 = {
                enable = true;
                position = "0x120";
                mode = "1920x1200";
              };
            };
          };
          # Sometimes after a clean reboot DP-1 and DP-2 are mixed up.
          "home-alt" = {
            fingerprint = {
              eDP-1 = "00ffffffffffff000daef21400000000161c0104a51f117802ee95a3544c99260f505400000001010101010101010101010101010101363680a0703820402e1e240035ad10000018000000fe004e3134304843472d4751320a20000000fe00434d4e0a202020202020202020000000fe004e3134304843472d4751320a2000bb";
              DP-1-8 = "00ffffffffffff0010aca6a04c39413015190104a55021783afd25a2584f9f260d5054a54b00714f81008180a940d1c0010101010101e77c70a0d0a029505020ca041e4f3100001a000000ff0036384d434635354a3041394c0a000000fc0044454c4c205533343135570a20000000fd0030551e5920000a2020202020200173020319f14c9005040302071601141f12132309070783010000023a801871382d40582c25001e4f3100001e584d00b8a1381440942cb5001e4f3100001e9d6770a0d0a0225050205a041e4f3100001a7a3eb85060a02950282068001e4f3100001a565e00a0a0a02950302035001e4f3100001a00000000000000000000000062";
              DP-2 = "00ffffffffffff0010acb8a0534657300f1b0104a53420783a0495a9554d9d26105054a54b00714f8180a940d1c0d100010101010101283c80a070b023403020360006442100001e000000ff00374d543031373444305746530a000000fc0044454c4c2055323431350a2020000000fd00313d1e5311000a202020202020011402031cf14f9005040302071601141f12132021222309070783010000023a801871382d40582c450006442100001e011d8018711c1620582c250006442100009e011d007251d01e206e28550006442100001e8c0ad08a20e02d10103e96000644210000180000000000000000000000000000000000000000000000000000000c";
            };
            config = {
              eDP-1.enable = false;
              DP-1-8 = {
                enable = true;
                primary = true;
                position = "1920x0";
                mode = "3440x1440";
              };
              DP-2 = {
                enable = true;
                position = "0x120";
                mode = "1920x1200";
              };
            };
          };
          "work-denhaag" = {
            fingerprint = {
              eDP-1 = "00ffffffffffff000daef21400000000161c0104a51f117802ee95a3544c99260f505400000001010101010101010101010101010101363680a0703820402e1e240035ad10000018000000fe004e3134304843472d4751320a20000000fe00434d4e0a202020202020202020000000fe004e3134304843472d4751320a2000bb";
              HDMI-1 = "00ffffffffffff00220e6934010101011b1c010380351e782a0565a756529c270f5054a10800d1c081c0a9c0b3009500810081800101023a801871382d40582c45000f282100001e000000fd00323c1e5011000a202020202020000000fc00485020453234330a2020202020000000ff00434e4338323731524e300a202001cd020319b149901f0413031202110167030c0010000022e2002b023a801871382d40582c45000f282100001e023a80d072382d40102c45800f282100001e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001";
            };
            config = {
              eDP-1 = {
                enable = true;
                position = "0x1080";
                mode = "1920x1080";
              };
              HDMI-1 = {
                enable = true;
                primary = true;
                position = "0x0";
                mode = "1920x1080";
              };
            };
          };
          "work-utrecht" = {
            fingerprint = {
              eDP-1 = "00ffffffffffff000daef21400000000161c0104a51f117802ee95a3544c99260f505400000001010101010101010101010101010101363680a0703820402e1e240035ad10000018000000fe004e3134304843472d4751320a20000000fe00434d4e0a202020202020202020000000fe004e3134304843472d4751320a2000bb";
              DP-1 = "00ffffffffffff004c2d250e30335230251d0104a55021783ae345a754529925125054bfef80714f810081c081809500a9c0b3000101e77c70a0d0a0295030203a001d4d3100001a000000fd0032641e9837000a202020202020000000fc00433334483839780a2020202020000000ff0048544f4d3930303230380a202001fe020314f147901f041303125a23090707830100004ed470a0d0a0465030203a001d4d3100001a9d6770a0d0a0225030203a001d4d3100001a565e00a0a0a02950302035001d4d3100001a023a801871382d40582c450000000000001e584d00b8a1381440f82c45001d4d3100001e00000000000000000000000000000000004c";
            };
            config = {
              eDP-1 = {
                enable = true;
                position = "760x1440";
                mode = "1920x1080";
              };
              DP-1 = {
                enable = true;
                primary = true;
                position = "0x0";
                mode = "3440x1440";
              };
            };
          };
        };
      };
  
    };
  };
}
