# MacOS system with nix-darwin, can be complemented with user specific home-manager separately.
{ pkgs, ... }: {
  ids.gids.nixbld = 30000;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  nixpkgs.config.allowUnfree = true;

  system.activationScripts.postActivation.text = ''
      $DRY_RUN_CMD grep -q 'pam_tid.so' /etc/pam.d/sudo || /usr/bin/sudo ${pkgs.gnused}/bin/sed -i '2i\
      auth       sufficient     pam_tid.so
      ' /etc/pam.d/sudo
      $DRY_RUN_CMD grep -q 'pam_reattach.so' /etc/pam.d/sudo || /usr/bin/sudo ${pkgs.gnused}/bin/sed -i '2i\
      auth       optional       /opt/homebrew/lib/pam/pam_reattach.so
      ' /etc/pam.d/sudo
  '';

  # Required by zsh autocompletion, managed by home-manager.
  programs.zsh.enable = true;
  environment.pathsToLink = [ "/share/zsh" ];

  environment.launchDaemons = {
    "com.apple.locate.plist".source = "/System/Library/LaunchDaemons/com.apple.locate.plist";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.hack  # Required by Starship, Neovim.
  ];

  system = {
    stateVersion = 5;
    primaryUser = "kciredor";  # XXX: See https://github.com/nix-darwin/nix-darwin/pull/1341#issuecomment-2666080741.

    defaults = {
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

      loginwindow.GuestEnabled = false;

      NSGlobalDomain = {
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticWindowAnimationsEnabled = false;
        NSDocumentSaveNewDocumentsToCloud = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;
      };

      dock = {
        orientation = "right";
        autohide = true;
        show-recents = false;
        tilesize = 34;
        mineffect = "scale";
        mru-spaces = false;
        static-only = true;
      };

      finder = {
        ShowPathbar = true;
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        FXDefaultSearchScope = "SCcf";  # Searches current folder.
        FXPreferredViewStyle = "Nlsv";  # List view.
      };

      CustomUserPreferences = {
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.TextEdit" = {
          RichText = 0;
          NSShowAppCentricOpenPanelInsteadOfUntitledFile = false;
        };
        "com.apple.print.PrintingPrefs" = {
          "Quit When Finished" = true;
        };
        "com.apple.finder" = {
          WarnOnEmptyTrash = false;
        };
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };

  networking.applicationFirewall = {
    enable = true;
    blockAllIncoming = true;
    allowSigned = false;
    allowSignedApp = false;
  };

  homebrew = {
    enable = true;

    global = {
      autoUpdate = false;
    };

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    brews = [
      "pam-reattach"  # Required by sudo via TouchID.
      "pinentry-mac"
    ];

    casks = [
      "backblaze"
      "1password"
      "alacritty"
      "google-chrome"
      "google-drive"
      "cloudflare-warp"
      "hammerspoon"
      "obsidian"
      "signal"
      "spotify"

      "docker-desktop"
      "vmware-fusion"
      "visual-studio-code"
      "zed"  # Configured in zed.nix.

      "tradingview"
      "logitech-g-hub"
      "ableton-live-suite"
      "native-access"

      "firefox"  # Temp.
    ];

    # Mac AppStore apps will not be automatically uninstalled when removed from the list.
    masApps = {
      Logic-Pro = 634148309;
      Tailscale = 1475387142;

      # Safari extensions.
      Wipr = 1320666476;
      Vimium = 1480933944;
    };
  };
}
