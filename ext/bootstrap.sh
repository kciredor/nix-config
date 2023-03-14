#!/usr/bin/env bash

set -e

echo "kciredor's Linux configuration."

# 0: Setup repo.
if [[ ! -e $HOME/ops/nix-config ]]; then
    mkdir -p $HOME/ops
    cd $HOME/ops
    git clone --recursive https://github.com/kciredor/nix-config.git
    cd nix-config
    git remote rm origin
    git remote add origin git@github.com:kciredor/nix-config.git
fi
cd $HOME/ops/nix-config

# 1: Nix.
curl -L https://nixos.org/nix/install | sh
. $HOME/.nix-profile/etc/profile.d/nix.sh
mkdir -p ~/.config/nix
echo "experimental-features = nix-command" >> $HOME/.config/nix/nix.conf
mkdir -p ~/.config/nixpkgs
echo -ne "{\n  allowUnfree = true;\n}" >> $HOME/.config/nixpkgs/config.nix
nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
nix-channel --update

# 2: Home-Manager.
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
rm -f $HOME/.config/home-manager/home.nix
ln -s /home/kciredor/ops/nix-config/ext/home.nix $HOME/.config/home-manager/home.nix
home-manager switch -b backup
echo "/home/kciredor/.nix-profile/bin/fish" | sudo tee -a /etc/shells
chsh -s /home/kciredor/.nix-profile/bin/fish
echo -ne "\n\n** BOOTSTRAP COMPLETED - Now logout/login or reboot **\n\n"
