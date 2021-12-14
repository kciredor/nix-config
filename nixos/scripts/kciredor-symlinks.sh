#!/usr/bin/env bash

set -xe

# Ensures compatibility with bootstrap.sh compensating for nixos-install not processing system.userActivationScripts.
[[ -z $SOURCE ]] && SOURCE=$HOME
[[ -z $TARGET ]] && TARGET=$HOME

# Binary Ninja.
[[ -e $TARGET/.binaryninja ]] || ln -s $SOURCE/ops/nixos/config/dotfiles/.binaryninja $TARGET/.binaryninja

# Ghidra.
export GHIDRA_DOTDIR=$TARGET/.ghidra/.$(grep -Eo "ghidra_.*zip" /etc/nixos/configuration.nix | rev | cut -d _ -f2- | rev)
mkdir -p $GHIDRA_DOTDIR

[[ -L $GHIDRA_DOTDIR/preferences ]] || (rm -f $GHIDRA_DOTDIR/preferences && ln -s $SOURCE/ops/nixos/config/dotfiles/.ghidra/preferences $GHIDRA_DOTDIR/preferences)
