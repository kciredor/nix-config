#!/bin/bash

set -xe

type -P systemctl >/dev/null || (echo "systemctl not found in path" && exit 1)
type -P sudo >/dev/null || (echo "sudo not found in path" && exit 1)
type -P curl >/dev/null || (echo "curl not found in path" && exit 1)
type -P xz >/dev/null || (echo "xz not found in path" && exit 1)

sh <(curl -L https://nixos.org/nix/install) --daemon
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >>$HOME/.config/nix/nix.conf
mkdir -p ~/.config/nixpkgs
echo -ne "{\n  allowUnfree = true;\n}" >>$HOME/.config/nixpkgs/config.nix
PATH=/nix/var/nix/profiles/default/bin:$PATH

rm -f ~/.bashrc ~/.profile
HOSTNAME=$(hostnamectl --pretty hostname)
if [[ ${#HOSTNAME} == 0 ]]; then HOSTNAME=$(hostname); fi
nix build ".#homeConfigurations.$USER@$HOSTNAME.activationPackage"
./result/activate
rm -rf ./result
