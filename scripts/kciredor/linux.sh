#!/usr/bin/env bash

set -e

UNAME=$(uname -a)
if [[ $UNAME == *'Darwin'* || $UNAME == *'NixOS'* ]]; then
  exit
fi

# Fills the gap for non-NixOS Linux distro's.
echo "[Activation script] scripts/kciredor/linux.sh"
PATH=/etc/profiles/per-user/kciredor/bin:/home/kciredor/.nix-profile/bin:/bin:/usr/bin:$PATH

if ! grep -q nix-profile /etc/shells; then
  echo "/home/kciredor/.nix-profile/bin/fish" | sudo tee -a /etc/shells
  chsh -s /home/kciredor/.nix-profile/bin/fish
fi

if [[ ! -e /usr/share/xsessions/home-manager.desktop ]]; then
  cat << EOF | sudo tee /usr/share/xsessions/home-manager.desktop >/dev/null
[Desktop Entry]
Name=Xsession
Exec=/etc/X11/Xsession
X-GDM-SessionRegisters=true
EOF
fi

if ! grep -q ardelay /etc/gdm3/custom.conf; then
  sudo sed -i "s/\[daemon\]/\[daemon\]\nxserver-command=X -ardelay 170 -arinterval 15/" /etc/gdm3/custom.conf
fi
