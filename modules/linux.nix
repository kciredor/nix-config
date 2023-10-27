{ pkgs, ... }: {
  systemd.user.startServices = "sd-switch";

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraMono" ]; })  # Includes powerline and fontawesome. Required by Starship, Neovim, i3status-rust.

    gdb
  ];
}
