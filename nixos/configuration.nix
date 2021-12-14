###################################
# kciredor's NixOS configuration. #
###################################

# TODO
# - More shell aliases.
# - X
#   - i3 basics: switch/close windows.
#   - autolock
# - Apps
#   - Firefox with settings and extensions.
#   - Neovim.
#   - Custom packages: https://nixos.org/manual/nixos/stable/index.html#sec-custom-packages #2: include from repo into c.nix.
#     - Coreboot configurator: https://github.com/StarLabsLtd/coreboot-configurator
#     - Binary Ninja: ready, just needs the include.
#     - IDA Pro
#   - Default apps: xdg-mime-apps module in home-manager -> should fix tmux urlview.
#   - Neomutt.
# - Backups: Borg (via Vorta or Borgmatic)

{ config, pkgs, lib, ... }:

let

in {
  # Initial version.
  system.stateVersion = "21.11";

  # Imports.
  imports = [
    ./hardware-configuration.nix

    <home-manager/nixos>
  ];

  # Running inside VMware needs these to be enabled.
  virtualisation.vmware.guest.enable = true;
  services.openssh.enable = true;

  # Bootloader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "nodev";
    efiSupport = true;
    enableCryptodisk = true;
  };
  boot.initrd.luks.devices = {
      storage = {
        device = "/dev/nvme0n1p2";
        preLVM = true;
        # TODO: trim support? "lsblk --discard And check the values of DISC-GRAN (discard granularity) and DISC-MAX (discard max bytes) columns. Non-zero values indicate TRIM support."
        #                     "Alternatively, install hdparm package and run: hdparm -I /dev/sda | grep TRIM"
        # allowDiscards = true;
        # + fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];
      };
  };

  # Networking.
  networking.hostName = "rs-sb";
  networking.usePredictableInterfaceNames = false;
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true; 
  networking.networkmanager.enable = true;  # NOTE: nmcli device wifi rescan ; nmcli device wifi connect <ssid> --ask -> nm-applet.
  # networking.firewall.allowedTCPPorts = lib.mkForce [];  # Force close all ports. Runnig inside VMware needs this to be disabled.
  # networking.firewall.allowedUDPPorts = lib.mkForce [];  # " "

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
      vim
      curl
      htop
      ripgrep
      gdb

      networkmanagerapplet
    ];
  };

  # Custom packages.
  nixpkgs.overlays = [(self: super: {
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

  # Virtualisation.
  virtualisation.docker.enable = true;

  # X11.
  services.xserver = {
    enable = true;

    layout = "dvorak";
    xkbOptions = "eurosign:e";  # caps:swapescape
    # TODO: autoRepeatDelay / autoRepeatInterval.

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
      extraPackages = with pkgs; [
        i3lock-color
      ];
    };

    displayManager.defaultSession = "xfce+i3";
  };

  systemd.user.services.nm-applet.enable = true;

  # Misc services.
  services.locate = {
    enable = true;
    interval = "hourly";
  };

  # TODO: printer
  # services.printing.enable = true;

  # TODO: sound (pipewire-pulse?)
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # TODO: touchpad
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # TODO: gpg/ssh agent -> via home-manager?
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  #############################################################################

  # Users.
  users = {
    mutableUsers = false;

    users.root.hashedPassword = "!";

    users.kciredor = {
      uid = 1000;
      isNormalUser = true;
      extraGroups = [ "wheel" "audio" "video" "networkmanager" "docker" ];
      shell = pkgs.zsh;

      # Workaround for passwordFile during both initial install and rebuilds while having /etc/nixos symlinked.
      # See: https://github.com/NixOS/nixpkgs/issues/148044.
      hashedPassword = lib.strings.fileContents ./secrets/kciredor-password.txt;
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

  # NOTE: These are NOT being run by the initial 'nixos-install', only by 'nixos-rebuild switch' (or boot + an actual reboot).
  system.userActivationScripts = {
    # Symlinks some of kciredor's versioned dotfiles which are not currently provisioned by NixOS or Home-Manager.
    symlinks.text = ''
      if [[ $USER == "kciredor" ]]; then
        source ${config.system.build.setEnvironment}

        $HOME/ops/nixos/config/nixos/scripts/kciredor-symlinks.sh
      fi
    '';
  };

  # User packages and dotfiles.
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;

    users.kciredor = { config, pkgs, lib, ... }: {
      home.packages = with pkgs; [
        (nerdfonts.override { fonts = [ "FiraCode" ]; })  # Required by Starship.
        powerline-fonts  # Required by Starship.
        exa
        kubectl

        xsel  # Required by tmux plugin yank.

        standardnotes

        unstable.todoist-electron

        myGhidra
      ];

      programs.zsh = {
        enable = true;

        dotDir = ".config/zsh";
        defaultKeymap = "viins";
        autocd = false;
        enableAutosuggestions = true;
        enableVteIntegration = true;
        enableCompletion = true;

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
          # TODO: ... aliases (3 t/m 5)
          # TODO: git aliases: glgg, gss, gc, gp

          ls = "exa";
          l  = "exa -lg";
          la = "exa -alg";
          lr = "exa -lRg";
          lt = "exa --tree";
          lg = "exa -g --long --git";

          vinix = "vim ~/ops/nixos/config/nixos/configuration.nix";
          rebuild = "sudo nix-channel --update && sudo nixos-rebuild switch";
        };
      };

      home.file.".gdbinit".text = ''
        set auto-load safe-path /nix/store

        layout regs
      '';

      programs.starship = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          # format = lib.concatStrings [
          #   "$directory"
          #   "$line_break"
          # ];
          # right_format = "$kubernetes"
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

      programs.git = {
        enable = true;
        userName = "kciredor";
        userEmail = "roderick@wehandle.it";
        # TODO: gpg, rebase > merge, cleanup, etc.
      };

      programs.neovim = {
        enable = true;
        package = pkgs.unstable.neovim-unwrapped;

        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;

        # Example with includes: https://breuer.dev/blog/nixos-home-manager-neovim, 
        # with extraConfig = builtins.readFile ./init.vim https://github.com/SenchoPens/senixos/blob/master/modules/applications/nvim/default.nix
        extraConfig = ''
            set sw=4 ts=4
            set expandtab
        '';

        # plugins = with pkgs.vimPlugins; [
        #   yankring
        # ];

        # python3, nodejs, etc

        # TODO
        # - automated PlugInstall
        # - full nvimrc dotfile -or- plugins via config and 'extraConfig' include file.
        #
        # https://discourse.nixos.org/t/proper-way-to-install-neovim-plugins-without-home-manager/11837
        # https://framagit.org/vegaelle/nix-nvim
        # https://rycee.gitlab.io/home-manager/options.html
        # https://github.com/nix-community/home-manager/blob/master/modules/programs/neovim.nix
      };

      # TODO: https://github.com/nix-community/home-manager/blob/master/modules/services/window-managers/i3-sway/i3.nix.
      # NOTE: Next step is dropping xserver block which manages XFCE, set xsession.enable = true, bare i3 + autorandr.
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
            "${config.modifier}+Shift+e" = "exec xfce4-session-logout";
            "${config.modifier}+F12" = "exec i3lock-color -c 00000000 --indicator";
          };
        };
      };
      # xdg.configFile."i3blocks/config".source = ./i3blocks.conf;

      programs.alacritty = {
        enable = true;

        settings = {
          key_bindings = [
            { key = "Return"; mods = "Command|Shift"; action = "SpawnNewInstance"; }
          ];
        };
      };

      programs.firefox = {
        enable = true;

        # TODO
        profiles.kciredor = {
          settings = {
            "browser.startup.homepage" = "https://kciredor.com/";
            # "browser.search.region" = "GB";
            # "browser.search.isUS" = false;
            # "distribution.searchplugins.defaultLocale" = "en-GB";
            # "general.useragent.locale" = "en-GB";
            # "browser.bookmarks.showMobileBookmarks" = true;
          };

          # extraConfig = '';  # user.js
        };

        # TODO: nix-env -f '<nixpkgs>' -qaP -A nur.repos.rycee.firefox-addons -> https://github.com/nix-community/NUR
        # NOTE: 21.11: Firefox v91 does not support addons with invalid signature anymore. Firefox ESR needs to be used for nix addon support.
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          https-everywhere
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
