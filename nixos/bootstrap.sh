#!/usr/bin/env bash

set -e

echo "kciredor's NixOS configuration."

echo -ne "\n** Partitioning **\n\n"
set -x
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB
parted /dev/nvme0n1 -- set 1 esp on
# Adding 25gb partition for a dual boot OS like Ubuntu allowing for proper firmware upgrades, which is too buggy with NixOS.
# See: https://github.com/StarLabsLtd/firmware/issues/24.
parted /dev/nvme0n1 -- mkpart primary 512MiB 26112MiB
parted /dev/nvme0n1 -- mkpart primary 26112MiB 100%
parted /dev/nvme0n1 -- set 3 lvm on
set +x

echo -ne "\n** Setting up encryption **\n\n"
set -x
cryptsetup luksFormat /dev/nvme0n1p3
cryptsetup open --type luks /dev/nvme0n1p3 lvm
pvcreate /dev/mapper/lvm
vgcreate storage /dev/mapper/lvm
lvcreate -L 64G storage -n swap
lvcreate -L 200G storage -n root
lvcreate -l +100%FREE storage -n home
set +x

echo -ne "\n** Formatting filesystems **\n\n"
set -x
mkswap /dev/mapper/storage-swap
mkfs.fat -F 32 -n boot /dev/nvme0n1p1
mkfs.xfs -L root /dev/mapper/storage-root
mkfs.xfs -L home /dev/mapper/storage-home
set +x

echo -ne "\n** Mounting filesystems **\n\n"
set -x
swapon /dev/storage/swap
mount /dev/disk/by-label/root /mnt
mkdir /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
mkdir /mnt/home
mount /dev/disk/by-label/home /mnt/home
set +x

echo -ne "\n** Fetching NixOS configuration **\n\n"
set -x
nix-env -iA nixos.git
mkdir -p /mnt/home/kciredor/ops
cd /mnt/home/kciredor/ops
git clone --recursive https://github.com/kciredor/nix-config.git
cd nix-config
git remote rm origin
git remote add origin git@github.com:kciredor/nix-config.git
set +x

echo -ne "\n** Applying NixOS configuration **\n\n"
set -x
nixos-generate-config --root /mnt
mv /mnt/etc/nixos/hardware-configuration.nix /mnt/home/kciredor/ops/nix-config/nixos/
rm -rf /mnt/etc/nixos
ln -s /mnt/home/kciredor/ops/nix-config/nixos /mnt/etc/nixos
/mnt/home/kciredor/ops/nix-config/scripts/root/nix-sources.sh
nix-prefetch-url --name displaylink-561.zip https://www.synaptics.com/sites/default/files/exe_files/2022-08/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu5.6.1-EXE.zip
mkdir /mnt/home/kciredor/ops/nix-config/secrets/kciredor
cp -R /mnt/home/kciredor/ops/nix-config/secrets/exampleuser/* /mnt/home/kciredor/ops/nix-config/secrets/kciredor/
echo "Enter new password for user kciredor"
mkpasswd -m sha-512 | tr -d '\n' > /mnt/home/kciredor/ops/nix-config/secrets/kciredor/passwd_hash
chmod 600 /mnt/home/kciredor/ops/nix-config/secrets/kciredor/passwd_hash
ln -s /mnt/home/kciredor /home/kciredor
nixos-install --no-root-passwd
set +x

echo -ne "\n** Post-install **\n\n"
set -x
chown -R 1000:100 /mnt/home/kciredor/ops
chmod -R o-rwx /mnt/home/kciredor/ops
rm -f /mnt/etc/nixos
ln -s /home/kciredor/ops/nix-config/nixos /mnt/etc/nixos
set +x

echo -ne "\n** DONE: PRESS ENTER TO REBOOT **\n\n"
read
reboot
