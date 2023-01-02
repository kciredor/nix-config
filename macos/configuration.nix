# TODO:
# - Alacritty in Dock + Spotlight - https://github.com/nix-community/home-manager/issues/1341
#   - Dock only shows running apps + disable Spotlight + separate launcher
#     - Hammerspoon or Raycast can serve as launchers and tiling window manager
#     - Opening Alacritty with Raycast allows for pinning to Dock
#     - Karabiner can (re)map keys
# - Tiling window manager?
# - Nixpkgs -unless- in which case it becomes homebrew (for casks anyway)
#   - brew install pam-reattach for touchid sudo
#   - brew tap homebrew/cask-drivers for yubico
#   - brew cask disable signing setting warning
#   - NOTE: https://github.com/LnL7/nix-darwin/pull/487
#           https://github.com/LnL7/nix-darwin/issues/139
#           https://github.com/nixos/nix/issues/956
# - Manage macOS configuration settings: system.defaults..., system.keyboard, ...
#   - Hostname
#   - Handmatige config naast home-manager: https://git.herrbischoff.com/awesome-macos-command-line/about/
#   - Multiple desktops alvast aanmaken
#   - README: inloggen settings:gmail, dropbox, etc


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
    auto-optimise-store = true
    experimental-features = nix-command
  '';
  nixpkgs.config.allowUnfree = true;

  system = {
    defaults = {
      NSGlobalDomain = {
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
      };
      dock = {
        orientation = "right";
        autohide = true;
        show-recents = false;
        tilesize = 34;
        mineffect = "scale";
        mru-spaces = false;
        # TODO: Magnification and others via custom shell commands.
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

  # FIXME: Does not work yet with for example tmux.
  fonts = {
    fontDir.enable = true;

    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraMono" ]; })
    ];
  };

  programs.fish.enable = true;

  users.users.root = {};
  users.users.kciredor = {
    name = "kciredor";
    home = "/Users/kciredor";
  };
}
