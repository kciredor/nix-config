###################################
# kciredor's NixOS configuration. #
###################################

# TODO
# - Hardware
#   - Audio: docked speakers require 'pavucontrol -> output -> toggle mute off / on' and having fallback enabled. Or is TLP autosuspend USB be in the way?
#   - Bluetooth headsets (see Pipewire config again).
# - Neomutt including mbsync.
# - Backups with Borg (using Vorta or Borgmatic)
#
# - Next
#   - Split up configuration.nix: starbook.nix, x.nix, home.nix, (custom)packages.nix, ...
#   - Custom packages: https://nixos.org/manual/nixos/stable/index.html#sec-custom-packages #2: include from repo into c.nix.
#     - Binary Ninja: ready, just needs the include.
#     - IDA Pro
#   - 'gef missing'.
#   - Try Polybar instead of i3status(-rust).
#   - Try Wayland with Sway instead of Xorg with i3.

{ config, pkgs, lib, ... }:

let

in {
  # Initial version.
  system.stateVersion = "21.11";

  # Imports.
  imports = [
    ./hardware-configuration.nix

    # StarBook related.
    <nixos-hardware/common/cpu/intel>  # Includes i915.
    <nixos-hardware/common/pc/laptop>  # Enables tlp.
    <nixos-hardware/common/pc/laptop/ssd>  # Enables weekly trimming.

    <home-manager/nixos>
  ];

  # Firmware, StarBook related.
  # FIXME: Older fwupd does not detect Coreboot firmware, see https://github.com/NixOS/nixpkgs/issues/153238.
  services.fwupd.enable = true;

  # Bootloader.
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };
  boot.initrd.luks.devices = {
      storage = {
        device = "/dev/nvme0n1p2";
        preLVM = true;
        allowDiscards = true;  # StarBook actually recommends disabling discard/trim.
      };
  };

  # Kernel.
  # XXX: Required by DisplayLink to be disabled for now because of bug in their most recent driver package on latest kernels.
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # Power management.
  services.upower.enable = true;  # StarBook related, included by XFCE as well.
  services.logind.lidSwitch = "suspend-then-hibernate";

  # Bluetooth.
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Virtualisation.
  virtualisation.docker.enable = true;

  # Networking.
  networking = {
    hostName = "rs-sb";
    usePredictableInterfaceNames = false;

    # Using dnsmasq ensures wireguard up and down does not clear resolv.conf.
    networkmanager = {
      enable = true;
      dns = "dnsmasq";
    };

    firewall = {
      # Force close all ports.
      allowedTCPPorts = lib.mkForce [];
      allowedUDPPorts = lib.mkForce [];

      # Allow wireguard traffic through rpfilter.
      extraCommands = ''
        ip46tables -t raw -I nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN
        ip46tables -t raw -I nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN
      '';
      extraStopCommands = ''
        ip46tables -t raw -D nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
        ip46tables -t raw -D nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
      '';
    };
  };

  # VPN.
  environment.etc = {
    "NetworkManager/system-connections/vpn.nmconnection" = {
      source = "/etc/nixos/secrets/kciredor/vpn.nmconnection";
      mode = "0600";
    };
  };

  # Timezone, locale and keyboard map.
  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "dvorak";
  };

  # Packages setup.
  nixpkgs.config = {
    allowUnfree = true;

    packageOverrides = pkgs: {
      unstable = import <nixos-unstable> {
        config = config.nixpkgs.config;
      };

      nur = import <nur> {
        inherit pkgs;
      };
    };
  };

  # System packages.
  environment = {
    shells = [ pkgs.zsh ];
    pathsToLink = [ "/share/zsh" ];  # Required by zsh enableCompletion.
    variables = {
      EDITOR = "vim";
    };

    systemPackages = with pkgs; [
      myFlashrom

      vim
      curl
      htop
      ripgrep
      gdb

      pulseaudio  # Required by volume buttons bound in i3.
      pavucontrol  # Required by i3status icon.
      arandr
    ];
  };

  # Custom packages.
  nixpkgs.overlays = [(self: super: {
    # XXX: Latest flashrom release v1.2 is 2 years old and does not detect chipset, see https://github.com/StarLabsLtd/firmware/issues/24#issuecomment-1007455366.
    myFlashrom = super.flashrom.overrideAttrs (old: {
      version = "1.2-custom";
      src = builtins.fetchGit {
        url = "https://github.com/flashrom/flashrom.git";
        ref = "b5dc7418e22c15b83e412419099a6d311c5f9f66";
      };
      patches = [];
      postPatch = ''
        echo "#!/bin/sh" > util/getrevision.sh
        echo "echo 1.2-custom" >> util/getrevision.sh
        chmod 755 util/getrevision.sh
        patchShebangs util/getrevision.sh
      '';
      postInstall = ''
        install -Dm644 util/flashrom_udev.rules $out/lib/udev/rules.d/flashrom.rules
      '';
    });

    myGhidra = super.ghidra-bin.overrideAttrs (old: {
      version = "10.1";
      src = super.fetchzip {
        url = "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.1_build/ghidra_10.1_PUBLIC_20211210.zip";
        sha256 = "0b4wn2nwxp96dpg3xpabqh74xxv0fhwmqq04wgfjgdh6bavqk86b";
      };
    });
  })];

  # Store maintenance.
  nix = {
    autoOptimiseStore = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Boot scripts.
  systemd.services.nix-sources = {
    script = lib.strings.fileContents ./scripts/nix-sources.sh;
    wantedBy = [ "network-online.target" ];
  };

  # X11.
  services.xserver = {
    enable = true;

    # StarBook related, recommended Intel Iris settings by NixOS. Needs picom as well to prevent tearing (configured by home-manager). Also adds DisplayLink support.
    # FIXME: nixos-install does not find displaylink.zip.
    videoDrivers = [ "displaylink" "modesetting" ];
    useGlamor = true;

    layout = "dvorak";
    xkbOptions = "eurosign:e, caps:swapescape";

    # Does not seem to work, neither does setting AutoRepeat option on keyboard catchall.
    autoRepeatDelay = 170;
    autoRepeatInterval = 70;

    libinput = {
      enable = true;  # Enabled by default by most desktopmanagers.
      touchpad.naturalScrolling = true;
    };

    # XFCE can be used together with i3.
    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };

    # i3 is configured by Home Manager.
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
    };

    displayManager.defaultSession = "none+i3";

    displayManager.sessionCommands = ''
      # Allows for a second external monitor.
      ${lib.getBin pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 2 0

      # XFCE should not run ssh-agent on top of gpg-agent.
      xfconf-query -c xfce4-session -p /startup/ssh-agent/enabled -n -t bool -s false

      # XFCE does not honor settings.xserver.[autoRepeatDelay|autoRepeatInterval].
      xfconf-query -c keyboards -p /Default/KeyRepeat/Delay -s 170
      xfconf-query -c keyboards -p /Default/KeyRepeat/Rate -s 70

      # i3 does not honor settings.xserver.[autoRepeatDelay|autoRepeatInterval].
      xset r rate 170 70
    '';
  };

  # Brightness buttons.
  services.illum.enable = true;

  # File indexing.
  services.locate = {
    enable = true;
    locate = pkgs.mlocate;
    localuser = null;
    interval = "hourly";
  };

  # Udev rules.
  services.udev.packages = [
    pkgs.myFlashrom
    pkgs.yubikey-personalization
  ];

  # Yubikey.
  services.pcscd.enable = true;
  programs.ssh.startAgent = false;

  # Sound.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Printer.
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      hplip  # Connection lpd://ip/queue.
    ];
    webInterface = true;
  };

  #############################################################################

  # Users.
  users = {
    mutableUsers = false;

    users.root.hashedPassword = "!";

    users.kciredor = {
      uid = 1000;
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "docker" "flashrom" ];
      shell = pkgs.zsh;

      # Workaround for passwordFile during both initial install and rebuilds while having /etc/nixos symlinked.
      # See: https://github.com/NixOS/nixpkgs/issues/148044.
      hashedPassword = lib.strings.fileContents ./secrets/kciredor/passwd_hash;
    };
  };

  security.sudo.extraRules = [
    {
      users = [ "kciredor" ];
      commands = [
        {
          command = "ALL" ;
          options= [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # User packages and dotfiles.
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;

    users.kciredor = { config, pkgs, lib, ... }: {
      home.packages = with pkgs; [
        nerdfonts  # Includes powerline and fontawesome. Required by Starship, i3status-rust, vim-lualine and vim-bufferline.

        exa
        unzip
        kubectl
        kubectx
        google-cloud-sdk
        awscli
        azure-cli
        python39
        rustc
        rustfmt
        cargo
        binutils-unwrapped  # Required by gdb-gef.

        xsel  # Required by tmux-yank.
        scrot
        feh
        i3lock-color
        yubioath-desktop
        standardnotes
        todoist-electron
        rambox
        spotify

        myGhidra
      ];

      # User scripts are activated by `nixos-rebuild boot` upon reboot covering nixos-install and during `nixos-rebuild switch`.
      home.activation = {
        userscripts = lib.hm.dag.entryAfter ["writeBoundary"] ''
          $DRY_RUN_CMD $HOME/ops/nixos/config/nixos/scripts/kciredor/yubikey.sh $VERBOSE_ARG
          $DRY_RUN_CMD $HOME/ops/nixos/config/nixos/scripts/kciredor/symlinks.sh $VERBOSE_ARG
        '';
      };

      # Systemd unit maintenance (sd-switch is the future default).
      systemd.user.startServices = "sd-switch";

      # Required by DisplayLink.
      programs.autorandr = {
        enable = true;

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
              DVI-I-1-1 = "00ffffffffffff0010acaaa04c3941301519010380502178eafd25a2584f9f260d5054a54b00714f81008180a940d1c0010101010101e77c70a0d0a029505020ca041e4f3100001a000000ff0036384d434635354a3041394c0a000000fc0044454c4c205533343135570a20000000fd0030551e5920000a20202020202001e5020320f14d9005040302071601141f12135a2309070765030c002000830100009d6770a0d0a0225050205a041e4f3100001a9f3d70a0d0a0155050208a001e4f3100001a584d00b8a1381440942cb5001e4f3100001e7a3eb85060a02950282068001e4f3100001a565e00a0a0a02950302035001e4f3100001a000000000048";
              DVI-I-2-2 = "00ffffffffffff0010acbaa0534657300f1b010380342078ea0495a9554d9d26105054a54b00714f8180a940d1c0d100010101010101283c80a070b023403020360006442100001e000000ff00374d543031373444305746530a000000fc0044454c4c2055323431350a2020000000fd00313d1e5311000a2020202020200188020322f14f9005040302071601141f12132021222309070765030c00100083010000023a801871382d40582c450006442100001e011d8018711c1620582c250006442100009e011d007251d01e206e28550006442100001e8c0ad08a20e02d10103e960006442100001800000000000000000000000000000000000000000082";
            };
            config = {
              eDP-1.enable = false;
              DVI-I-1-1 = {
                enable = true;
                primary = true;
                position = "1920x0";
                mode = "3440x1440";
              };
              DVI-I-2-2 = {
                enable = true;
                position = "0x120";
                mode = "1920x1200";
              };
            };
          };
        };
      };

      programs.zsh = {
        enable = true;

        dotDir = ".config/zsh";
        defaultKeymap = "viins";
        autocd = false;
        enableAutosuggestions = true;
        enableVteIntegration = true;
        enableCompletion = true;
        enableSyntaxHighlighting = true;

        history = {
          size = 100000;
          extended = true;
          path = ".config/zsh/.zsh_history";
        };

        envExtra = ''
          EDITOR="nvim"
          PATH="/home/kciredor/bin:$PATH"
        '';

        initExtra = ''
          umask 027
        '';

        shellAliases = {
          vinix = "vim ~/ops/nixos/config/nixos/configuration.nix";
          rebuild = "sudo nix-channel --update && sudo nixos-rebuild switch";

          ls = "exa -g";
          l  = "ls -l";
          la = "ls -alg";
          lr = "ls -lRg";
          lt = "ls --tree";
          lg = "ls -g --long --git";

          ".." = "cd ../";
          "..." = "cd ../../";
          "...." = "cd ../../../";
          "....." = "cd ../../../../";

          gss = "git status -s";
          gco = "git checkout";
          gp = "git push";
          gc = "git commit -v";
          glgg = "git log --graph";

          clip = "xsel -b";
        };
      };

      home.file.".gdbinit".text = ''
        set auto-load safe-path /nix/store

        source ~/ops/nixos/config/nixos/includes/kciredor/gef.py
      '';

      programs.starship = {
        enable = true;
        enableZshIntegration = true;

        settings = {
          directory = {
            truncation_length = 0;
            truncate_to_repo = false;
          };

          format = "$directory$character";

          right_format = lib.concatStrings [
            "$all"
          ];

          git_branch.format = "[$symbol$branch]($style) ";

          kubernetes = {
            disabled = false;
            format = "[$symbol$context( \($namespace\))]($style) ";
          };

          aws.disabled = true;
          gcloud.disabled = true;
        };
      };

      programs.tmux = {
        enable = true;

        clock24 = true;
        aggressiveResize = true;
        baseIndex = 1;
        historyLimit = 250000;
        escapeTime = 0;
        keyMode = "vi";
        terminal = "screen-256color";

        extraConfig = ''
          setw -g monitor-activity on
          set  -g visual-activity on
          set  -g status-interval 1
          set  -g repeat-time 300
          set  -g mouse on

          bind-key -T copy-mode-vi v send-keys -X begin-selection
          bind T setw synchronize-panes
        '';

        plugins = with pkgs.tmuxPlugins; [
          sensible
          pain-control
          yank
          urlview

          {
            plugin = power-theme;
            extraConfig = "set -g @tmux_power_theme '#483D8B'";
          }
        ];
      };

      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.autojump = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.gpg = {
        enable = true;

        # Defaults are based on drduh's hardened config, only adding what was missing.
        settings = {
          throw-keyids = "";
        };

        # Play nice between agent and totp.
        scdaemonSettings = {
          disable-ccid = true;
        };

        mutableKeys = false;
        mutableTrust = false;
        publicKeys = [
          {
            source = ./includes/kciredor/gpg_pubkey;
            trust = 5;
          }
        ];
      };

      services.gpg-agent = {
        enable = true;

        enableSshSupport = true;
        pinentryFlavor = "gtk2";  # Curses tends to open in the wrong terminal.
      };

      programs.ssh = {
        enable = true;
        forwardAgent = false;
        serverAliveInterval = 120;

        includes = [
          "${config.home.homeDirectory}/ops/nixos/config/nixos/secrets/kciredor/ssh_hosts"
        ];
      };

      programs.git = {
        enable = true;

        userName = "Roderick Schaefer";
        userEmail = "roderick@wehandle.it";

        signing = {
          signByDefault = true;
          key = "0x31FDA5E3FE0CB640";
        };

        ignores = [ "*~" ];

        aliases = {
          cleanup = "!git branch --merged | grep  -v '\\*\\|master\\|develop' | xargs -n 1 git branch -d";
        };

        includes = [
          {
            contents = {
              branch = {
                autosetuprebase = "always";
              };

              push = {
                default = "tracking";
              };

              merge = {
                tool = "vimdiff";
              };

              mergetool = {
                keepBackup = false;
                prompt = false;
              };
            };
          }
        ];
      };

      programs.neovim = {
        enable = true;
        package = pkgs.unstable.neovim-unwrapped;

        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;

        # Added ../../ prefix to paths for initial nixos-install compatibility.
        extraConfig = builtins.concatStringsSep "\n" [
          (lib.strings.fileContents ../../home/kciredor/ops/nixos/config/dotfiles/kciredor/neovim/base.vim)
          (lib.strings.fileContents ../../home/kciredor/ops/nixos/config/dotfiles/kciredor/neovim/plugins.vim)

          ''
            lua << EOF
            ${lib.strings.fileContents ../../home/kciredor/ops/nixos/config/dotfiles/kciredor/neovim/plugins.lua}
            ${lib.strings.fileContents ../../home/kciredor/ops/nixos/config/dotfiles/kciredor/neovim/lsp.lua}
            EOF
          ''
        ];

        extraPackages = with pkgs; [
          tree-sitter
          ctags  # Required by tagbar.

          # LSP.
          nodePackages.pyright
          gopls
          rust-analyzer
        ];

        plugins = with pkgs.vimPlugins;
          let
            vimPluginGit = ref: repo: pkgs.vimUtils.buildVimPluginFrom2Nix {
              pname = "${lib.strings.sanitizeDerivationName repo}";
              version = ref;
              src = builtins.fetchGit {
                url = "https://github.com/${repo}.git";
                ref = ref;
              };
            };

          in [
            # Theme.
            tokyonight-nvim

            # Basics.
            (vimPluginGit "master" "nvim-lualine/lualine.nvim")  # XXX: Package lualine-nvim contains deprecated diagnostics get_count calls.
            bufferline-nvim
            { plugin = nvim-web-devicons; optional = true; }  # Required by lualine and bufferline.
            nerdtree
            fzfWrapper
            fzf-vim
            (vimPluginGit "master" "bfredl/nvim-miniyank")

            # Coding.
            (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))  # Replaces 'ensure_installed = "maintained"' plugin config.
            tagbar
            vim-gitgutter
            vim-fugitive
            vim-go
            rust-vim

            # LSP including completion and snippets.
            nvim-lspconfig
            nvim-cmp
            cmp-nvim-lsp
            cmp_luasnip
            luasnip
            friendly-snippets
          ];
      };

      programs.go = {
        enable = true;
        goPath = "dev/go";
      };

      # StarBook related, this fixes screen tearing with Intel Iris.
      services.picom = {
        enable = true;
        vSync = true;
        inactiveDim = "0.2";
      };

      # Media buttons daemon.
      services.playerctld.enable = true;

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
            "${config.modifier}+F10" = "exec xset r rate 170 70; exec autorandr -c";
            "${config.modifier}+F11" = "exec systemctl suspend-then-hibernate";
            "${config.modifier}+F12" = "exec i3lock-color -c 000000 --indicator";

            "${config.modifier}+h" = "exec i3 workspace next";
            "${config.modifier}+l" = "exec i3 workspace previous";
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
          bindsym Print                 exec "scrot -m '%Y%m%d_%H%M%S.png' -e 'mv $f ~/images/screenshots/'"
          bindsym --release Shift+Print exec "scrot -s '%Y%m%d_%H%M%S.png' -e 'mv $f ~/images/screenshots/'"
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
                player = "spotify";
                on_collapsed_click = "spotify";
                buttons = [ "play" "next" ];
              }
              {
                block = "custom";
                command = "echo -n ' '; dropbox status | head -n 1";
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
            settings = {
              theme.name = "plain";
            };
            icons = "awesome5";
            theme = "gruvbox-dark";
          };
        };
      };

      services.screen-locker = {
        enable = true;

        inactiveInterval = 10;
        lockCmd = "${pkgs.i3lock-color}/bin/i3lock-color -n -c 000000 --indicator";
      };

      programs.alacritty = {
        enable = true;

        settings = {
          font.size = 10;

          key_bindings = [
            { key = "Return"; mods = "Command|Shift"; action = "SpawnNewInstance"; }
          ];

          env = {
            # Required by multi monitor setup with different DPI.
            WINIT_X11_SCALE_FACTOR = "1";
          };
        };
      };

      programs.firefox = {
        enable = true;

        profiles.kciredor = {
          settings = {
            # General
            "browser.warnOnQuitShortcut" = false;
            "browser.aboutConfig.showWarning" = false;
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
            "browser.toolbars.bookmarks.visibility" = "always";
            "browser.download.dir" = "${config.home.homeDirectory}/down";

            # Home
            "browser.startup.homepage" = "about:blank";
            "browser.newtabpage.enabled" = false;

            # Search: via StartPage addon (overrides browser.urlbar.placeholderName when enabled).

            # Privacy & Security
            "privacy.donottrackheader.enabled" = true;
            "dom.security.https_only_mode" = true;
            "signon.rememberSignons" = false;
            "toolkit.telemetry.enabled" = false;
            "toolkit.telemetry.reportingpolicy.firstRun" = false;
            "toolkit.telemetry.server" = "";
            "app.shield.optoutstudies.enabled" = false; # klopt deze?

            # Sync
            "services.sync.engine.addons" = false;
            "services.sync.engine.creditcards" = false;
            "services.sync.engine.passwords" = false;
            "services.sync.engine.prefs" = false;
          };
        };

        # See: https://github.com/nix-community/nur-combined/blob/master/repos/rycee/pkgs/firefox-addons/generated-firefox-addons.nix.
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          startpage-private-search

          onepassword-password-manager
          vimium
          ublock-origin
        ];
      };

      # Using home-manager version (without tray icon) until nixpkgs has a dropbox package with systemd unit.
      # See: https://github.com/NixOS/nixpkgs/pull/85699.
      services.dropbox = {
        enable = true;
        path = "${config.home.homeDirectory}/dropbox";
      };
    };
  };
}
