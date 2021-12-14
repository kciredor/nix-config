#!/usr/bin/env bash

# nix-sources.sh ensures sources are up to date from both new system bootstrap.sh and nixos-rebuild runs.
# Inlining sources in configuration.nix works as well, but then you don't have access to the sources using nix-env from the cli.

PATH=/run/current-system/sw/bin/:$PATH
OUTPUT=$(nix-channel --list)
REFRESH=0

if [[ ! $OUTPUT =~ nixos-unstable ]]; then
  REFRESH=1

  nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
fi

if [[ ! $OUTPUT =~ home-manager ]]; then
  REFRESH=1

  nix-channel --add https://github.com/nix-community/home-manager/archive/release-21.11.tar.gz home-manager
fi

if [[ ! $OUTPUT =~ nur ]]; then
  REFRESH=1

  nix-channel --add https://github.com/nix-community/NUR/archive/master.tar.gz nur
fi

if [[ $REFRESH -eq 1 ]]; then
  nix-channel --update
fi
