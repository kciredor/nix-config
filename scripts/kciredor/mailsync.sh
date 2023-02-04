#!/usr/bin/env bash

set -e

echo "[Activation script] scripts/kciredor/mailsync.sh"

if [[ "$(uname)" == "Darwin" ]]; then
  # MacOS is currently my main OS so it should sync mail.
  if ! /bin/launchctl list | grep -q com.notmuch; then
    /bin/launchctl load $HOME/Library/LaunchAgents/com.notmuch.plist
  fi
fi
