#!/usr/bin/env bash

# nix-sources.sh ensures sources are up to date from both new system bootstrap.sh and nixos-rebuild runs.
# Inlining sources in configuration.nix works as well, but then you don't have access to the sources using nix-env from the cli.

PATH=/run/current-system/sw/bin/:$PATH
OUTPUT=$(nix-channel --list)
REFRESH=0

if [[ ! $OUTPUT =~ nixos-hardware ]]; then
  REFRESH=1

  nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
fi

if [[ ! $OUTPUT =~ nixos-unstable ]]; then
  REFRESH=1

  nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
fi

if [[ ! $OUTPUT =~ home-manager ]]; then
  REFRESH=1

  nix-channel --add https://github.com/nix-community/home-manager/archive/release-21.11.tar.gz home-manager
fi

# Required by Firefox.
if [[ ! $OUTPUT =~ nur ]]; then
  REFRESH=1

  nix-channel --add https://github.com/nix-community/NUR/archive/master.tar.gz nur
fi

if [[ $REFRESH -eq 1 ]]; then
  nix-channel --update
fi

# Custom packages that need prefetching.
nix-store --query --requisites /run/current-system | cut -d- -f2- | sort | uniq | grep -q 'displaylink-5.4.1-55.174' || \
nix-prefetch-url --name displaylink.zip https://www.synaptics.com/sites/default/files/exe_files/2021-09/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu5.4.1-EXE.zip
