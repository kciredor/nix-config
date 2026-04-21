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
          model = "gemini-3.1-pro-preview";
        };
      };
      agent_servers = {
        gemini = {
          type = "registry";
        };
      };

      theme = {
        mode = "dark";
        light = "Gruvbox Light Hard";
        dark = "Gruvbox Dark";
      };

      title_bar = {
        show_sign_in = false;
      };

      telemetry = {
        "diagnostics" = false;
        "metrics" = false;
      };
    };
  };
}
