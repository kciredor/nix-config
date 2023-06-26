#!/usr/bin/env bash

NAME="rs-mbp14"

if [[ "$(uname)" == "Darwin" ]]; then
  if [[ "$(/usr/sbin/scutil --get ComputerName)" != "$NAME" ]]; then
    /usr/sbin/scutil --set ComputerName rs-mbp14
    /usr/sbin/scutil --set HostName rs-mbp14
    /usr/sbin/scutil --set LocalHostName rs-mbp14
  fi
fi
