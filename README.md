kciredor's Nix configuration for MacOS and Linux.
=================================================

# MacOS

- Clean install MacOS preferably with a case-sensitive and encrypted filesystem.
- Set username and hostname (`sudo scutil --set [ComputerName|HostName|LocalHostName] <name>`) matching [flake.nix](flake.nix).
- Clone this repository and run [bootstrap/macos.sh](bootstrap/macos.sh).

# Linux

- Boot from a freshly installed Linux distro of choice.
- Set username and hostname (pretty hostname is preferred) matching [flake.nix](flake.nix).
- Clone this repository and run [bootstrap/linux.sh](bootstrap/.sh).
