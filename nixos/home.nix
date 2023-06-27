{
  imports = [
    <home-manager/nixos>
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.root = { config, pkgs, lib, ... }: {
      home.stateVersion = "23.05";

      home.activation = {
        userscripts = lib.hm.dag.entryAfter ["writeBoundary"] ''
          $DRY_RUN_CMD /home/kciredor/ops/nix-config/scripts/root/borgssh.sh $VERBOSE_ARG
        '';
      };
    };
  
    users.kciredor = { config, pkgs, lib, ... }: lib.mkMerge[
      (import /home/kciredor/ops/nix-config/shared/home.nix { config = config; pkgs = pkgs; lib = lib; }).home
      (import /home/kciredor/ops/nix-config/shared/linux.nix { config = config; pkgs = pkgs; lib = lib; }).linux
      (import /home/kciredor/ops/nix-config/shared/desktop.nix { config = config; pkgs = pkgs; lib = lib; }).desktop
      {
        home.stateVersion = "23.05";

        home.packages = with pkgs; [
          unstable.yubioath-flutter
          unstable.ferdium

          myGhidra
        ];
  
        # Shared by all shells.
        home.shellAliases = {
          vinix   = "vim ~/ops/nix-config/nixos/configuration.nix ~/ops/nix-config/shared/home.nix ~/ops/nix-config/nixos/home.nix ~/ops/nix-config/shared/linux.nix ~/ops/nix-config/shared/desktop.nix";
          rebuild = "sudo nix-channel --update && sudo nixos-rebuild switch";
  
          clip = "xsel -b";
        };

        home.sessionVariables = {
          PATH = "/home/kciredor/bin:${builtins.getEnv "PATH"}";
        };

        services.keybase.enable = true;
  
        programs.chromium = {
          enable = true;
          package = pkgs.unstable.brave;
  
          extensions = [
            { id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; }  # 1password.
            { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; }  # Vimium.
            { id = "fihnjjcciajhdojfnbdddfaoknhalnja"; }  # I don't care about cookies.
            { id = "niloccemoadcdkdjlinkgdfekeahmflj"; }  # Pocket.
            { id = "kkmknnnjliniefekpicbaaobdnjjikfp"; }  # Cache killer.
          ];
        };
  
        # Using home-manager version (without tray icon) until nixpkgs has a dropbox package with systemd unit.
        # See: https://github.com/NixOS/nixpkgs/pull/85699.
        services.dropbox = {
          enable = true;
          path = "${config.home.homeDirectory}/dropbox";
        };

        xsession.windowManager.i3.config.terminal = "alacritty";
      }
    ];
  };
}
