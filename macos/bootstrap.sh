#!/bin/bash

set +x

# 0: Setup repo.
if [[ ! -e /Users/kciredor/ops/nix-config ]]; then
    mkdir -p /Users/kciredor/ops
    cd /Users/kciredor/ops
    git clone --recursive https://github.com/kciredor/nix-config.git
    cd nix-config
    git remote rm origin
    git remote add origin git@github.com:kciredor/nix-config.git
fi
cd /Users/kciredor/ops/nix-config

# 1: Nix.
curl -L https://nixos.org/nix/install | sh
. /etc/bashrc
mkdir -p ~/.config/nix
echo "experimental-features = nix-command" >> $HOME/.config/nix/nix.conf
nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
nix-channel --update

# 2: Home-Manager.
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

# 3: Nix-Darwin.
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer
. /etc/bashrc
rm -rf $HOME/.nixpkgs
rm -rf ./result
ln -s $(pwd)/configuration.nix $HOME/.config/nix/configuration.nix
sudo mv /etc/nix/nix.conf /etc/nix/.nix-darwin.bkp.nix.conf  # See: https://github.com/LnL7/nix-darwin/issues/149.
darwin-rebuild switch -I darwin-config=$HOME/.config/nix/configuration.nix
