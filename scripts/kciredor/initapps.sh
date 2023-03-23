#!/usr/bin/env bash

set -e

echo "[Activation script] scripts/kciredor/initapps.sh"
PATH=/etc/profiles/per-user/kciredor/bin:/home/kciredor/.nix-profile/bin:/bin:/usr/bin:$PATH

# Rust toolchain.
if [[ `rustup default 2>&1 | grep 'no default'`  ]]; then
    rustup default stable
fi
