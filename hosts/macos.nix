# MacOS system with nix-darwin, can be complemented with user specific home-manager separately.
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  services.nix-daemon.enable = true;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  nixpkgs.config.allowUnfree = true;

  system.activationScripts.postUserActivation.text = ''
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
    (nerdfonts.override { fonts = [ "Hack" ]; })  # Required by Starship, Neovim.
  ];

  system = {
    stateVersion = 5;

    defaults = {
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

      alf = {
        globalstate = 1;
        allowsignedenabled = 0;
        allowdownloadsignedenabled = 0;
      };

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

    caskArgs = {
      no_quarantine = true;
    };

    taps = [
      "homebrew/cask"
    ];

    brews = [
      "pam-reattach"  # Required by sudo via TouchID.
      "pinentry-mac"
    ];

    casks = [
      "backblaze"
      "1password"
      "google-chrome"
      "cloudflare-warp"
      "hammerspoon"
      "ferdium"
      "notion"
      "spotify"

      "docker"
      "vmware-fusion"

      "ghidra"
      "temurin"  # Required by Ghidra.
      "tradingview"

      "logitech-g-hub"
    ];

    # Mac AppStore apps will not be automatically uninstalled when removed from the list.
    masApps = {
      Logic-Pro = 634148309;

      # Safari extensions.
      Wipr = 1320666476;
      Vimium = 1480933944;
      Pocket = 1477385213;
    };
  };
}
