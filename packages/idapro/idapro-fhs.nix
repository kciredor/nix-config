with import <nixpkgs> {};

let
  ida-python = pkgs.python39.withPackages(p: with p; [
    pip

    six

    fuzzywuzzy       # Required by IDAFuzzy.
    keystone-engine  # Required by Keypatch.
  ]);

in (pkgs.buildFHSUserEnv {
  name = "idapro-fhs";

  targetPkgs = pkgs: (with pkgs; [
    zlib
    glib
    fontconfig
    dbus
    libglvnd
    libxkbcommon
    freetype

    libudev0-shim

    ida-python
    keystone         # Required by Keypatch.
  ]) ++ (with pkgs.xorg; [
    xorg.libX11
    xorg.libICE
    xorg.libSM
    xorg.libxcb
    xorg.xcbutilwm
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
  ]);

  runScript = "$HOME/opt/idapro/ida64";
})
