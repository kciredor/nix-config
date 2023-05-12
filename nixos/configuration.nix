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
    # Wireguard MTU is 1420 on an Azure VM (1392 works) and 1380 on a GCP vm.
    extraOptions = "--mtu 1280";
  };
  virtualisation.libvirtd.enable = true;
  virtualisation.vmware.host.enable = true;

  # Networking.
  networking = {
    hostName = "rs-sb";
    usePredictableInterfaceNames = false;

    networkmanager = {
      enable = true;
    };

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
    # Required by displaylink because otherwise the system freezes, see: https://support.displaylink.com/knowledgebase/articles/1843660-screen-freezes-after-opening-an-application-only.
    "modprobe.d/evdi.conf" = {
      text = "options evdi initial_device_count=2";
      mode = "0640";
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
      version = "10.3";
      src = super.fetchzip {
        url = "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.3_build/ghidra_10.3_PUBLIC_20230510.zip";
        sha256 = "sha256-uFyTMWhj3yMVIPxEwkLtTqpJUi2S8A2GFjjY3rNTC2c=";
      };
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
    script = lib.strings.fileContents /home/kciredor/ops/nix-config/scripts/root/nix-sources.sh;
    wantedBy = [ "network-online.target" ];
  };

  services.xserver = {
    enable = true;

    # Requires `nix-prefetch-url --name displaylink-561.zip https://www.synaptics.com/sites/default/files/exe_files/2022-08/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu5.6.1-EXE.zip`.
    videoDrivers = [ "displaylink" "modesetting" ];

    layout = "dvorak";
    xkbOptions = "eurosign:e, caps:swapescape";
    autoRepeatDelay = 170;  # -ardelay
    autoRepeatInterval = 15;  # -arinterval

    libinput.touchpad = {
      disableWhileTyping = true;
      naturalScrolling = true;
    };

    displayManager = {
      autoLogin.user = "kciredor";  # LUKS unlock already requires password at boot.

      session = [
        # Compatible with Home-Manager.
        {
          name = "xsession";
          manage = "window";
          start = ''
            ${pkgs.runtimeShell} $HOME/.xsession &
            waitPID=$!
          '';
        }
      ];

      # Required by displaylink to support more than one external monitor.
      sessionCommands = ''
        ${lib.getBin pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 2 0
      '';
    };
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
  programs.ssh.askPassword = "";

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
        "/home/kciredor/.cache"
        "/home/kciredor/.dropbox-hm/.dropbox/logs"
        "/home/kciredor/.config/Ferdi"

        "/home/kciredor/down"
        "/home/kciredor/tmp"
        "/home/kciredor/vm"
      ];
      repo = lib.strings.fileContents /home/kciredor/ops/nix-config/secrets/kciredor/borgbase_repo.url;
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
      extraGroups = [ "wheel" "networkmanager" "docker" "libvirtd" ];
      shell = pkgs.fish;

      # Workaround for passwordFile during both initial install and rebuilds while having /etc/nixos symlinked.
      # See: https://github.com/NixOS/nixpkgs/issues/148044.
      hashedPassword = lib.strings.fileContents /home/kciredor/ops/nix-config/secrets/kciredor/passwd_hash;
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
