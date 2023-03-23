#!/usr/bin/env bash

set -e

# MacOS is currently my main OS which should sync mail.
if [[ ! "$(uname)" == "Darwin" ]]; then
  exit
fi

echo "[Activation script] scripts/kciredor/mailsync.sh"
PATH=/etc/profiles/per-user/kciredor/bin:/home/kciredor/.nix-profile/bin:/bin:/usr/bin:$PATH

if ! launchctl list | grep -q com.notmuch; then
  launchctl load $HOME/Library/LaunchAgents/com.notmuch.plist
fi
