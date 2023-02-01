#!/usr/bin/env bash

NAME="rs-mbp13"

if [[ "$(uname)" == "Darwin" ]]; then
  if [[ "$(/usr/sbin/scutil --get ComputerName)" != "$NAME" ]]; then
    /usr/sbin/scutil --set ComputerName rs-mbp13
    /usr/sbin/scutil --set HostName rs-mbp13
    /usr/sbin/scutil --set LocalHostName rs-mbp13
  fi
fi
