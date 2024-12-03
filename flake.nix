{
  description = "kciredor's MacOS and Linux Nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    ...
  } @ inputs: let
    inherit (self) outputs;
  in {
    # Bootstrap using `bootstrap/macos.sh`.
    darwinConfigurations = {
      "macos" = nix-darwin.lib.darwinSystem {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./hosts/macos.nix
        ];
      };
    };

    # Bootstrap using `bootstrap/linux.sh`.
    homeConfigurations = {
      "kciredor@rs-mbp14" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        extraSpecialArgs = { inherit inputs outputs; };
        modules = [
          ./hosts/kciredor-rs-mbp14.nix
        ];
      };
      "kciredor@starbook" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs outputs; };
        modules = [
          ./hosts/kciredor-starbook.nix
        ];
      };
      # Bootstrap with env vars: NIX_FIRST_BUILD_UID=2000, NIX_BUILD_GROUP_ID=2000.
      "kciredor@cloudtop" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs outputs; };
        modules = [
          ./hosts/kciredor-cloudtop.nix
        ];
      };
    };
  };
}
