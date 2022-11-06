#!/usr/bin/env bash

set -e

echo "[Activation script] scripts/kciredor/initapps.sh"

# Rust toolchain.
if [[ `rustup default | grep 'no default'`  ]]; then
    rustup default stable
fi
