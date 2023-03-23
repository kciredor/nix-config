{ config, pkgs, lib, ... }:

let homeDir = if builtins.pathExists "/Users" then "/Users/kciredor" else "/home/kciredor";

in {
  linux = {
    # Systemd unit maintenance (sd-switch is the future default).
    systemd.user.startServices = "sd-switch";

    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraMono" ]; })  # Includes powerline and fontawesome. Required by Starship, i3status-rust, vim-lualine and vim-bufferline.
    ];

    services.gpg-agent = {
      enable = true;

      enableSshSupport = true;
      pinentryFlavor = "gtk2";  # Curses tends to open in the wrong terminal.
    };
  };
}
