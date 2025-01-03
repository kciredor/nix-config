{ pkgs, ... }: {
  systemd.user.startServices = "sd-switch";

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    nerd-fonts.fira-mono  # Includes powerline and fontawesome. Required by Starship, Neovim, i3status-rust.

    gdb
  ];
}
