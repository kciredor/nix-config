#!/bin/bash

set -xe

sh <(curl -L https://nixos.org/nix/install)
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >>$HOME/.config/nix/nix.conf
mkdir -p ~/.config/nixpkgs
echo -ne "{\n  allowUnfree = true;\n}" >>$HOME/.config/nixpkgs/config.nix
PATH=/nix/var/nix/profiles/default/bin:$PATH

bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

nix run nix-darwin -- switch --flake .#macos
PATH=/run/current-system/sw/bin:$PATH

rm -f ~/.bashrc ~/.profile
nix build ".#homeConfigurations.$USER@$HOSTNAME.activationPackage"
./result/activate
rm -rf ./result
