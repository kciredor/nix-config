{
  pkgs,
  ...
}: {
  programs.helix = {
    enable = true;
    defaultEditor = true;

    extraPackages = with pkgs; [
      nodePackages.bash-language-server

      nodePackages.pyright
      python3Packages.ruff-lsp
      gopls
      rust-analyzer
      clang

      terraform-ls
      nodePackages.dockerfile-language-server-nodejs
    ];

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

    languages = {
      language-server = {
        ruff.command = "ruff-lsp";
        rust-analyzer.config.check.command = "clippy";
      };

      language = [
        {
          name = "python";
          language-servers = [ "pyright" "ruff" ];

          # TODO: Add debugger support when implemented, see: https://github.com/helix-editor/helix/issues/5079.
        }
        {
          name = "go";
          auto-format = true;
          formatter = { command = "goimports"; };
        }
      ];
    };
  };
}
