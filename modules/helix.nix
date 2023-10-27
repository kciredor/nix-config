# See: https://github.com/nix-community/home-manager/issues/2923.
{
  pkgs,
  lib,
  ...
}: let
  helixPkgs = with pkgs; [
    nodePackages.bash-language-server
    python3Packages.python-lsp-server
    gopls
    rust-analyzer
  ];
  helixWrapped = pkgs.writeShellScriptBin "hx" ''
    PATH="${lib.makeBinPath helixPkgs}:$PATH"
    ${pkgs.helix}/bin/hx "$@"
  '';
in {
  programs.helix = {
    enable = true;
    package = helixWrapped;

    settings = {
      theme = "catppuccin_macchiato";
      editor = {
        bufferline = "always";
        cursorline = true;
        line-number = "relative";
        rulers = [120];

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        statusline = {
          center = ["version-control"];
        };

        file-picker = {
          hidden = false;
        };

        indent-guides = {
          render = true;
        };

        lsp = {
          display-messages = true;
        };
      };
    };
  };
}
