###################################
# kciredor's MacOS configuration. #
###################################

{ pkgs, ... }:
{
  imports = [ ./home.nix ];

  environment.darwinConfig = "$HOME/.config/nix/configuration.nix";
  services.nix-daemon.enable = true;
  nix.settings.trusted-users = [ "@admin" ];
  nix.extraOptions = ''
    experimental-features = nix-command
  '';
  nixpkgs.config.allowUnfree = true;

  system = {
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

  environment.launchDaemons = {
    "com.apple.locate.plist".source = "/System/Library/LaunchDaemons/com.apple.locate.plist";
  };

  fonts = {
    fontDir.enable = true;

    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "Hack" ]; })
    ];
  };

  programs.fish.enable = true;

  users.users.root = {};
  users.users.kciredor = {
    name = "kciredor";
    home = "/Users/kciredor";
  };

  homebrew = {
    enable = true;

    global = {
      autoUpdate = false;
    };

    onActivation = {
      autoUpdate = false;
      upgrade = true;
      cleanup = "zap";
    };

    caskArgs = {
      no_quarantine = true;
    };

    taps = [
      "homebrew/cask"
      "homebrew/cask-drivers"
    ];

    brews = [
      "pam-reattach"  # Required by sudo via TouchID.
      "pinentry-mac"

      "openjdk"  # Required by Ghidra.
      "libzip"  # Required by tsschecker.
    ];

    casks = [
      "backblaze"
      "hammerspoon"
      "1password"
      "yubico-authenticator"

      "logitech-g-hub"

      "brave-browser"
      "dropbox"
      "ferdium"

      "docker"
      "vmware-fusion"
      "google-cloud-sdk"  # NOTE: GKE needs `gcloud components install gke-gcloud-auth-plugin`.

      "ghidra"

      "notion"
      "screenflow"

      # VNG.
      "slack"
      "microsoft-office"
      "microsoft-teams"
      "zoom"

      # Logius.
      "webex"
      "citrix-workspace"
      "vmware-horizon-client"
      "displaylink"
      "openvpn-connect"
    ];

    # Mac AppStore apps will not be automatically uninstalled when removed from the list.
    masApps = {
      WireGuard = 1451685025;
      OnePassword-Browser = 1569813296;
      Logic-Pro = 634148309;
      Wipr = 1320666476;
    };
  };
}
