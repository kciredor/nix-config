# FIXME
# - Resolve Hammerspoon multi-monitor/screen issues.
# - Resolve Little Snitch nix binaries hash match changes after rebuilds -> back to Mac default firewall but enable Handoff / Airplay / Wireguard?
# TODO
# - Maildir from Linux to MacOS.
# - Use Dropbox to sync non-secret data between MacOS and Linux.


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
      alf.globalstate = 0;  # Disables built-in firewall and lets Little Snitch take control.
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

        # TODO: Magnification and others via custom shell commands or CustomSystem/UserPreferences.
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

      "azure-cli"  # XXX: nixpkgs azure-cli is broken currently on MacOS. Merge this one and macos/configuration.nix homebrew azure-cli back into shared/home.nix nixpkgs.

      "openjdk"  # Required by Ghidra.
      "libzip"  # Required by tsschecker.
    ];

    casks = [
      "backblaze"
      "hammerspoon"
      "1password"
      "yubico-authenticator"
      "little-snitch"

      # "logitech-g-hub"  # XXX: Installs and works but errors out about permissions (SIP related trying to chown).

      "brave-browser"
      "dropbox"
      "standard-notes"
      "todoist"
      "ferdium"

      "docker"
      "google-cloud-sdk"  # NOTE: GKE needs `gcloud components install gke-gcloud-auth-plugin`.

      "ghidra"

      "notion"
      "screenflow"

      # VNG.
      "slack"
      "microsoft-office"
      "microsoft-teams"

      # Logius.
      "webex"
      "citrix-workspace"
      "displaylink"
    ];

    # Mac AppStore apps will not be automatically uninstalled when removed from the list.
    masApps = {
      WireGuard = 1451685025;
      OnePassword-Browser = 1569813296;
      Logic-Pro = 634148309;

      # TODO: KeepingYouAwake via HammerSpoon plugin?
    };
  };
}
