#!/usr/bin/env bash

set -e

echo "[Activation script] scripts/kciredor/initapps.sh"

# Rust toolchain.
if [[ `rustup default 2>&1 | grep 'no default'`  ]]; then
    rustup default stable
fi
