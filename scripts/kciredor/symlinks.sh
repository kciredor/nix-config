#!/usr/bin/env bash

set -e

echo "[Activation script] scripts/kciredor/symlinks.sh"
PATH=/etc/profiles/per-user/kciredor/bin:/home/kciredor/.nix-profile/bin:/bin:/usr/bin:$PATH

# Wallpaper.
[[ -e $HOME/.background-image ]] || ln -s $HOME/ops/nix-config/dotfiles/kciredor/wallpapers/mountains.jpg $HOME/.background-image
[[ -e $HOME/.fehbg ]] || (ln -s $HOME/ops/nix-config/dotfiles/kciredor/fehbg $HOME/.fehbg && chmod 750 $HOME/.fehbg)

# IDA Pro.
[[ -e $HOME/.idapro ]] || ln -s $HOME/ops/nix-config/dotfiles/kciredor/idapro $HOME/.idapro

# Binary Ninja.
[[ -e $HOME/.binaryninja ]] || ln -s $HOME/ops/nix-config/dotfiles/kciredor/binaryninja $HOME/.binaryninja
if [[ "$(uname)" == "Darwin" && ! -e "$HOME/Library/Application Support/Binary Ninja" ]]; then
  ln -s $HOME/.binaryninja "$HOME/Library/Application Support/Binary Ninja"
fi

# Ghidra.
if [[ -e "/etc/nixos" ]]; then
  # NixOS.
  GHIDRA_DOTDIR=$HOME/.ghidra/.$(grep -Eo "ghidra_.*zip" /etc/nixos/configuration.nix | /run/current-system/sw/bin/rev | cut -d _ -f2- | /run/current-system/sw/bin/rev)
fi
if [[ "$(uname)" == "Darwin" ]]; then
  # MacOS.
  SCRIPT_FILE="$(readlink -f "/usr/local/bin/ghidraRun" 2>/dev/null || readlink "/usr/local/bin/ghidraRun" 2>/dev/null || echo "$0")"
  GHIDRA_DOTDIR="$HOME/.ghidra/.$(basename ${SCRIPT_FILE%/*})"

  xattr -r -d com.apple.quarantine /opt/homebrew/Caskroom/ghidra
fi
if [[ ! -z $GHIDRA_DOTDIR ]]; then
  mkdir -p $GHIDRA_DOTDIR
  [[ -L $GHIDRA_DOTDIR/preferences ]] || (rm -f $GHIDRA_DOTDIR/preferences && ln -s $HOME/ops/nix-config/dotfiles/kciredor/ghidra/preferences $GHIDRA_DOTDIR/preferences)
  [[ -L $HOME/.ghidra//README ]] || ln -s $HOME/ops/nix-config/dotfiles/kciredor/ghidra/README $HOME/.ghidra/README
  if [[ "$(uname)" == "Darwin" && ! -e $HOME/bin/ghidra.sh ]]; then
    ln -s $HOME/ops/nix-config/dotfiles/kciredor/ghidra/ghidra.sh $HOME/bin/ghidra.sh
  fi
fi

# Hammerspoon.
if [[ "$(uname)" == "Darwin" && ! -e $HOME/.hammerspoon ]]; then
  ln -s $HOME/ops/nix-config/dotfiles/kciredor/hammerspoon $HOME/.hammerspoon
fi

# Unversioned dotfiles.
for SOURCE in $HOME/ops/nix-config/dotfiles/kciredor/_unversioned/*; do
  SOURCE_FN=$(basename $SOURCE)
  TARGET=$HOME/.$SOURCE_FN

  if [[ $SOURCE_FN != "*" && ! -e $TARGET ]]; then
    ln -s $SOURCE $TARGET
  fi
done
