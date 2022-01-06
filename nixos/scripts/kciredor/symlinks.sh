#!/usr/bin/env bash

set -e

echo "[Activation script] scripts/kciredor/symlinks.sh"

# IDA Pro.
[[ -e $HOME/.idapro ]] || ln -s $HOME/ops/nixos/config/dotfiles/kciredor/idapro $HOME/.idapro

# Binary Ninja.
[[ -e $HOME/.binaryninja ]] || ln -s $HOME/ops/nixos/config/dotfiles/kciredor/binaryninja $HOME/.binaryninja

# Ghidra.
export GHIDRA_DOTDIR=$HOME/.ghidra/.$(grep -Eo "ghidra_.*zip" /etc/nixos/configuration.nix | rev | cut -d _ -f2- | rev)
mkdir -p $GHIDRA_DOTDIR

[[ -L $GHIDRA_DOTDIR/preferences ]] || (rm -f $GHIDRA_DOTDIR/preferences && ln -s $HOME/ops/nixos/config/dotfiles/kciredor/ghidra/preferences $GHIDRA_DOTDIR/preferences)

# Unversioned dotfiles.
for SOURCE in $HOME/ops/nixos/config/dotfiles/kciredor/_unversioned/*; do
  SOURCE_FN=$(basename $SOURCE)
  TARGET=$HOME/.$SOURCE_FN

  if [[ $SOURCE_FN != "*" && ! -e $TARGET ]]; then
    ln -s $SOURCE $TARGET
  fi
done
