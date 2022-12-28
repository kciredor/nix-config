###################################
# kciredor's NixOS configuration. #
###################################

{ config, pkgs, lib, ... }:

let

in {
  # Initial version.
  system.stateVersion = "22.11";

  # Imports.
  imports = [
    ./hardware-configuration.nix

    # StarBook related.
    <nixos-hardware/common/cpu/intel>  # Includes i915.
    <nixos-hardware/common/pc/laptop>  # Enables tlp.
    <nixos-hardware/common/pc/laptop/ssd>  # Enables weekly trimming.

    # Dotfiles.
    ./home.nix
  ];

  # Bootloader.
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };
  boot.initrd.luks.devices = {
      storage = {
        device = "/dev/nvme0n1p3";
        preLVM = true;
        allowDiscards = true;  # StarBook actually recommends disabling discard/trim.
      };
  };

  # Kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=0
  '';
  boot.kernelParams = [ "transparent_hugepage=never" ];  # Required by VMware host.

  # Power management.
  services.upower.enable = true;  # StarBook related, included by XFCE as well.
  services.logind.lidSwitch = "suspend-then-hibernate";
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=3h
  '';
  powerManagement.resumeCommands = ''
    systemctl restart illum.service
    systemctl --user --machine=kciredor@.host restart imapnotify-gmail.service
  '';

  # Bluetooth.
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Docking (configured by home-manager).
  services.autorandr = {
    enable = true;
    defaultTarget = "laptop";
  };

  # Virtualisation.
  virtualisation.docker = {
    enable = true;
    # Wireguard MTU is 1420.
    extraOptions = "--mtu 1392";
  };
  virtualisation.libvirtd.enable = true;
  virtualisation.vmware.host.enable = true;

  # Networking.
  networking = {
    hostName = "rs-sb";
    usePredictableInterfaceNames = false;

    networkmanager = {
      enable = true;
      dns = "none";
    };

    nameservers = [ "10.7.0.1" "1.1.1.1" "8.8.8.8" ];

    interfaces = {
        wlan0 = {
            # Allows for tunnelbroker.net IPv6 to function properly.
            mtu = 1480;
        };
    };

    firewall = {
      # Force close all ports.
      allowedTCPPorts = lib.mkForce [];
      allowedUDPPorts = lib.mkForce [];

      # Allow wireguard traffic through rpfilter.
      checkReversePath = "loose";
    };
  };

  # VPN.
  environment.etc = {
    "NetworkManager/system-connections/vpn.nmconnection" = {
      source = "/home/kciredor/ops/nix-config/secrets/kciredor/vpn.nmconnection";
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
    };
  };

  nix.extraOptions = ''
    trusted-users = root kciredor
  '';

  # System packages.
  environment = {
    variables = {
      EDITOR = "vim";
    };

    systemPackages = with pkgs; [
      vim
      curl
      htop
      ripgrep
      gdb
      gcc

      pulseaudio  # Required by volume buttons bound in i3.
      pavucontrol  # Required by i3status icon.
      arandr
      virt-manager  # Required by libvirtd.
    ];
  };

  # Custom packages.
  nixpkgs.overlays = [(self: super: {
    myGhidra = super.ghidra-bin.overrideAttrs (old: {
      # Pins latest public release.
      version = "10.2";
      src = super.fetchzip {
        url = "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.2_build/ghidra_10.2_PUBLIC_20221101.zip";
        sha256 = "sha256-H8SwOfYstzm7bUe2d/zB1ax705/SCQ49ZhACUfPz/zw=";
      };
      # Adds openjdk17 requirement as of Ghidra 10.2.
      postFixup = ''
        mkdir -p "$out/bin"
        ln -s "$out/lib/ghidra/ghidraRun" "$out/bin/ghidra"
        wrapProgram "$out/lib/ghidra/support/launch.sh" --prefix PATH : ${lib.makeBinPath [ pkgs.openjdk17 ]}
      '';
    });
  })];

  # Store maintenance.
  nix = {
    settings = {
      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Boot scripts.
  systemd.services.nix-sources = {
    script = lib.strings.fileContents ../../home/kciredor/ops/nix-config/scripts/root/nix-sources.sh;
    wantedBy = [ "network-online.target" ];
  };

  # X11.
  services.xserver = {
    enable = true;

    # StarBook related, recommended Intel Iris settings by NixOS. Needs picom as well to prevent tearing (configured by home-manager).
    videoDrivers = [ "modesetting" ];

    layout = "dvorak";
    xkbOptions = "eurosign:e, caps:swapescape";

    # Keyboard repeat rate via seat default. Interval = 1000 / <xset interval>.
    autoRepeatDelay = 170;
    autoRepeatInterval = 15;

    libinput = {
      enable = true;  # Enabled by default by most desktopmanagers.
      touchpad = {
        disableWhileTyping = true;
        naturalScrolling = true;
      };
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

  # Enable fish shell (configured by home-manager).
  programs.fish.enable = true;

  # Required by libvirtd.
  programs.dconf.enable = true;

  # Backups using Borg.
  services.borgbackup.jobs = {
    borgbase = {
      paths = [
        "/home"
      ];
      exclude = [
        ".cache"

        "/home/kciredor/.config/Ferdi"

        "/home/kciredor/down"
        "/home/kciredor/tmp"
        "/home/kciredor/vm"
      ];
      repo = lib.strings.fileContents ../../home/kciredor/ops/nix-config/secrets/kciredor/borgbase_repo.url;
      encryption = {
        mode = "repokey-blake2";
        passCommand = "/home/kciredor/ops/nix-config/secrets/kciredor/borgbase_passphrase.sh";
      };
      environment = {
        BORG_RSH = "ssh -i /home/kciredor/ops/nix-config/secrets/kciredor/borgbase_ssh";
      };
      compression = "auto,lzma";
      startAt = [ "daily" ];
      extraCreateArgs = "--verbose --stats --checkpoint-interval 600";
      prune.keep = {
        within = "1d";
        daily = 7;
        weekly = 4;
        monthly = 6;
      };
    };
  };

  #############################################################################

  # Users.
  users = {
    mutableUsers = false;

    users.root.hashedPassword = "!";

    users.kciredor = {
      uid = 1000;
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "docker" "libvirtd" "vboxusers" ];
      shell = pkgs.fish;

      # Workaround for passwordFile during both initial install and rebuilds while having /etc/nixos symlinked.
      # See: https://github.com/NixOS/nixpkgs/issues/148044.
      hashedPassword = lib.strings.fileContents ../../home/kciredor/ops/nix-config/secrets/kciredor/passwd_hash;
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
}
