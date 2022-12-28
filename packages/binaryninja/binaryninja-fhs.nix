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

  # Core debugger lldb dependency requires a specific ncurses version and perhaps will be statically linked in the future.
  # Workaround: copy over 3 files from Ubuntu 22.04 LTS: libncurses.so.6, libpanel.so.6, libtinfo.so.6.
  profile = ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/ops/nixos-config/packages/binaryninja/libs_from_ubuntu_2204
  '';

  runScript = "$HOME/opt/binaryninja/binaryninja";
})
