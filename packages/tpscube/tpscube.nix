with import <nixpkgs> {};

rustPlatform.buildRustPackage rec {
  name = "tpscube";
  version = "git-21d56ce";

  src = fetchFromGitHub {
    owner = "D0ntPanic";
    repo = "tpscube";
    rev = "21d56cee955c90149099bb489fb60d1de4a77f0c";
    sha256 = "sha256-sCLLYf0zrgqR4s2s/glg2NRsEtZB2k+fdhk6PB4msus=";
  };

  cargoSha256 = "sha256-9DBsT/LQU+yYhe9uRbUnODo67YEtRFR6hnuWoOUiUgs=";

  doCheck = false;

  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";

  buildInputs = [
    dbus
    openssl
    libGL
    libxkbcommon

    xorg.libX11
    xorg.libXext
    xorg.libXcursor
    xorg.libxcb
    xorg.libXrandr
    xorg.libXi
  ];

  nativeBuildInputs = [
    makeWrapper

    clang
    cmake
    pkg-config
    python3
    curl
  ];

  # Dirty hack to work around a dependency of a dependency being curled in.
  # Requires `nix-build --no-sandbox tpscube.nix` and your username in nix options as a trusted user.
  preBuild = ''
    sed -i 's/\"-o\"/\"-k\", \"-o\"/' ../tpscube-vendor.tar.gz/sdl2-sys/build.rs
    sed -i 's/f215221f99aa512b24a247ba3500287aa183fdc964a4256a4888fbf8f991282c/ae0f3f107017c852a3c4380e8abd2e4af0c7fdc1310a46cf57a28eb2c15acdfb/' ../tpscube-vendor.tar.gz/sdl2-sys/.cargo-checksum.json
  '';

  postInstall = ''
    wrapProgram $out/bin/tpscube \
      --set LD_LIBRARY_PATH "${libGL}/lib" \
      --set SDL_VIDEODRIVER "dummy"
  '';
}
