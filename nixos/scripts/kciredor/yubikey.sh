#!/usr/bin/env bash

set -e

echo "[Activation script] scripts/kciredor/yubikey.sh"

PRIVPATH=$HOME/.gnupg/private-keys-v1.d
SHOULDCREATE=0

if [ ! -d $PRIVPATH ]; then
  SHOULDCREATE=1
elif [ -z "$(ls -A $PRIVPATH)" ]; then
  SHOULDCREATE=1
fi

if [ $SHOULDCREATE == 1 ]; then
  # This is tricky during boot. May or may not work.
  gpg-connect-agent "scd serialno" "learn --force" /bye || echo "* Yubikey not found *"

  # Cleans up gpg-agent spawned during boot which is running as a daemon vs supervised later in the process.
  kill $(pgrep -f 'gpg-agent.*daemon') 2>/dev/null || true
fi
