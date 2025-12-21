{
  programs.zed-editor = {
    enable = true;

    # Installed by Homebrew in hosts/macos.nix and by Nix package in modules/linux-desktop.nix.
    package = null;

    mutableUserSettings = false;

    userSettings = {
      vim_mode = true;
      search = {
        regex = true;
      };
      use_smartcase_search = true;

      agent = {
        default_model = {
          provider = "google";
          model = "gemini-3-pro-preview";
        };
      };

      theme = {
        mode = "dark";
        light = "Gruvbox Light Hard";
        dark = "Gruvbox Dark";
      };

      telemetry = {
        "diagnostics" = false;
        "metrics" = false;
      };
    };
  };
}
