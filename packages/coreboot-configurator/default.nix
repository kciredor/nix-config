# XXX
with import <nixpkgs> {};
#{ stdenv
#, fetchFromGitHub
#, meson
#, ninja
#, pkg-config
#, qt5.qtbase
#, qt5.qttools
#, wrapQtAppsHook
#, nvramtool
#, sudo
#}:

stdenv.mkDerivation rec {
  pname = "coreboot-configurator";
  version = "0abbc835";

  src = fetchFromGitHub {
    owner = "StarLabsLtd";
    repo = "coreboot-configurator";
    rev = "${version}";
    sha256 = "1rk161gpljb985af5m88j68wbh175n0kgjbh16lzpgf4kcbd8hnl";
  };

  buildInputs = [ qt5.qtbase qt5.qttools nvramtool ];
  nativeBuildInputs = [ qt5.wrapQtAppsHook meson ninja pkg-config cmake libyamlcpp inkscape ];

  prePatch = ''
    sed -i 's|/usr/bin/pkexec|sudo|g' src/application/NvramToolCli.cpp
    sed -i 's|/usr/sbin/nvramtool|${pkgs.nvramtool}/bin/nvramtool|g' src/application/NvramToolCli.cpp
    sed -i 's|/usr/sbin/nvramtool|${pkgs.nvramtool}/bin/nvramtool|g' src/resources/org.coreboot.nvramtool.policy
  '';

  configurePhase = "meson build --prefix=$out";
  buildPhase = "ninja -C build";
  installPhase = "ninja -C build install";

  meta = {
    homepage = "https://starlabs.systems/";
    description = "A simple GUI to change settings in coreboot's CBFS, via the nvramtool utility.";
  };
}
