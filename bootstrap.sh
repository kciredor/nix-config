#!/usr/bin/env bash

set -e

echo "kciredor's NixOS configuration."

echo -ne "\n** Partitioning **\n\n"
set -x
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB
parted /dev/nvme0n1 -- set 1 esp on
parted /dev/nvme0n1 -- mkpart primary 512MiB 100%
parted /dev/nvme0n1 -- set 2 lvm on
set +x

echo -ne "\n** Setting up encryption **\n\n"
set -x
cryptsetup luksFormat /dev/nvme0n1p2
cryptsetup open --type luks /dev/nvme0n1p2 lvm
pvcreate /dev/mapper/lvm
vgcreate storage /dev/mapper/lvm
lvcreate -L 64G storage -n swap
lvcreate -L 500G storage -n root
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
mkdir -p /mnt/home/kciredor/ops/nixos
cd /mnt/home/kciredor/ops/nixos
git clone --recursive https://github.com/kciredor/nixos-config.git config
cd config
git remote rm origin
git remote add origin git@github.com:kciredor/nixos-config.git
set +x

echo -ne "\n** Applying NixOS configuration **\n\n"
set -x
nixos-generate-config --root /mnt
mv /mnt/etc/nixos/hardware-configuration.nix /mnt/home/kciredor/ops/nixos/config/nixos/
rm -rf /mnt/etc/nixos
ln -s /mnt/home/kciredor/ops/nixos/config/nixos /mnt/etc/nixos
/mnt/home/kciredor/ops/nixos/config/nixos/scripts/nix-sources.sh
echo "Enter new password for user kciredor"
mkdir /mnt/home/kciredor/ops/nixos/config/nixos/secrets/kciredor
mkpasswd -m sha-512 | tr -d '\n' > /mnt/home/kciredor/ops/nixos/config/nixos/secrets/kciredor/passwd_hash
chmod 600 /mnt/home/kciredor/ops/nixos/config/nixos/secrets/kciredor/passwd_hash
nixos-install --no-root-passwd
set +x

echo -ne "\n** Post-install **\n\n"
set -x
chown -R 1000:100 /mnt/home/kciredor/ops
chmod -R o-rwx /mnt/home/kciredor/ops
rm -f /mnt/etc/nixos
ln -s /home/kciredor/ops/nixos/config/nixos /mnt/etc/nixos
set +x

echo -ne "\n** DONE: PRESS ENTER TO REBOOT **\n\n"
read
reboot
