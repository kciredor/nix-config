with import <nixpkgs> {};

let
  bn-python = pkgs.python310.withPackages(p: with p; [
    # Support BN plugin manager: requires BN setting which overrides python path to /usr/bin/python.
    pip
  ]);

in (pkgs.buildFHSUserEnv {
  name = "binaryninja-fhs";

  # Thanks to @xmppwocky/BN Slack.
  targetPkgs = pkgs: (with pkgs; [
    stdenv.cc.cc

    zlib
    glib
    fontconfig
    dbus
    libglvnd
    libxkbcommon
    alsa-lib
    nss
    krb5
    freetype
    nspr
    expat

    libudev0-shim

    bn-python
  ]) ++ (with pkgs.xorg; [
    xorg.libX11
    xorg.libXi
    xorg.libXfixes
    xorg.libXrender
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXcursor
    xorg.libXext
    xorg.libxcb
    xorg.libXtst
    xorg.libXrandr
    xorg.xcbutilwm
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
  ]);

  runScript = "$HOME/opt/binaryninja/binaryninja";
})
