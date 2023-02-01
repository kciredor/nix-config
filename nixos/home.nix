{
  imports = [
    <home-manager/nixos>

    /home/kciredor/ops/nix-config/shared/home.nix
    /home/kciredor/ops/nix-config/nixos/desktop.nix
    /home/kciredor/ops/nix-config/nixos/mail.nix
  ];

  home-manager = {
    users.root = { config, pkgs, lib, ... }: {
      home.stateVersion = "22.11";

      home.activation = {
        userscripts = lib.hm.dag.entryAfter ["writeBoundary"] ''
          $DRY_RUN_CMD /home/kciredor/ops/nix-config/scripts/root/borgssh.sh $VERBOSE_ARG
        '';
      };
    };
  
    users.kciredor = { config, pkgs, lib, ... }: {
      home.stateVersion = "22.11";

      home.packages = with pkgs; [
        (nerdfonts.override { fonts = [ "FiraMono" ]; })  # Includes powerline and fontawesome. Required by Starship, i3status-rust, vim-lualine and vim-bufferline.

        gdb

        libnotify
        xsel  # Required by tmux-yank.
        scrot
        feh
        i3lock-color
        unstable.yubioath-flutter
        cider
        chromium

        azure-cli  # XXX: nixpkgs azure-cli is broken currently on MacOS. Merge this one and macos/configuration.nix homebrew azure-cli back into shared/home.nix nixpkgs.

        unstable.standardnotes
        unstable.ferdium
        unstable.webex
  
        myGhidra
      ];
  
      # Systemd unit maintenance (sd-switch is the future default).
      systemd.user.startServices = "sd-switch";
  
      fonts.fontconfig.enable = true;
  
      # Shared by all shells.
      home.shellAliases = {
        vinix   = "vim ~/ops/nix-config/nixos/configuration.nix ~/ops/nix-config/shared/home.nix ~/ops/nix-config/nixos/home.nix ~/ops/nix-config/nixos/desktop.nix ~/ops/nix-config/nixos/mail.nix";
        rebuild = "sudo nix-channel --update && sudo nixos-rebuild switch";
  
        clip = "xsel -b";
      };

      home.file.".gdbinit".text = ''
        set auto-load safe-path /nix/store

        source ~/ops/nix-config/includes/kciredor/gef.py
      '';
  
      services.gpg-agent = {
        enable = true;
  
        enableSshSupport = true;
        pinentryFlavor = "gtk2";  # Curses tends to open in the wrong terminal.
      };
  
      services.keybase.enable = true;
  
      programs.chromium = {
        enable = true;
        package = pkgs.unstable.brave;
  
        extensions = [
          { id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; }  # 1password.
          { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; }  # Vimium.
          { id = "fihnjjcciajhdojfnbdddfaoknhalnja"; }  # I don't care about cookies.
          { id = "niloccemoadcdkdjlinkgdfekeahmflj"; }  # Pocket.
          { id = "kkmknnnjliniefekpicbaaobdnjjikfp"; }  # Cache killer.
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
