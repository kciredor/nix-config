with import <nixpkgs> {};

let
  bn-python = pkgs.python39.withPackages(p: with p; [
    # Support BN plugin manager: requires BN setting which overrides python path to /usr/bin/python.
    pip

    # Alteratively you can pre-package requirements.
    # colorama  # Required by 'Debugger' plugin.
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
  ]) ++ (with pkgs.xlibs; [
    xlibs.libX11
    xlibs.libXi
    xlibs.libXfixes
    xlibs.libXrender
    xlibs.libXcomposite
    xlibs.libXdamage
    xlibs.libXcursor
    xlibs.libXext
    xlibs.libxcb
    xlibs.libXtst
    xlibs.libXrandr
    xlibs.xcbutilwm
    xlibs.xcbutilimage
    xlibs.xcbutilkeysyms
    xlibs.xcbutilrenderutil
  ]);

  runScript = "$HOME/opt/binaryninja/binaryninja";
})
