# Ubuntu on StarBook MkV with home-manager for user kciredor with desktop specifics.
#
# Install KVM:
# - apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
# - systemctl enable --now libvirtd
# - usermod -aG libvirt,kvm kciredor
#
# Install VMware:
# - apt install build-essentials
# - https://softwareupdate.vmware.com/cds/vmw-desktop/ws/

{
  imports = [
    ../modules/home.nix
    ../modules/linux.nix
    ../modules/linux-desktop.nix
  ];

  home = {
    username = "kciredor";
    homeDirectory = "/home/kciredor";
    stateVersion = "24.11";
  };

  home.shellAliases = {
    rebuild = "home-manager switch -b backup --flake $HOME/nix-config#kciredor@starbook";
    vinix   = "vim ~/nix-config/flake.nix ~/nix-config/hosts/kciredor-starbook.nix ~/nix-config/modules/home.nix ~/nix-config/modules/linux.nix ~/nix-config/modules/linux-desktop.nix";
  };

  programs.git = {
    settings = {
      user = {
        name = "Roderick Schaefer";
        email = "roderick@kciredor.com";
      };
    };
  };

  # Required by Chrome OS VM.
  programs.zsh.initContent = ''
    export PATH="$HOME/src/depot_tools:$PATH"
  '';
}
