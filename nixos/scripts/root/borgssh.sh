#!/usr/bin/env bash

set -e

echo "[Activation script] scripts/root/borgssh.sh"

if [[ -f $HOME/../home/kciredor/ops/nixos/config/nixos/secrets/kciredor/borgbase_repo.url ]]; then
  mkdir -p $HOME/.ssh
  touch $HOME/.ssh/known_hosts

  # This path is compatible with initial bootstrap and nixos-rebuild.
  BORG_HOST=$(cat $HOME/../home/kciredor/ops/nixos/config/nixos/secrets/kciredor/borgbase_repo.url | sed 's/.*@\(.*\)\:repo/\1/')

  if [[ `echo $BORG_HOST | grep borgbase.com` ]]; then
    if [[ ! `grep $BORG_HOST $HOME/.ssh/known_hosts` ]]; then
      ssh-keyscan $BORG_HOST 2>/dev/null >> $HOME/.ssh/known_hosts
    fi
  fi

  chmod -R go-rwx $HOME/.ssh
fi
