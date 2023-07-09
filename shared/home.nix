{ config, pkgs, lib, ... }:

# This works both with sudo (NixOS) and without sudo (MacOS, other Linux) rebuilds.
let homeDir = if builtins.pathExists "/Users" then "/Users/kciredor" else "/home/kciredor";

in {
  home = {
    home.packages = with pkgs; [
      coreutils
      diffutils
      findutils
      gnused
      gnutar
      gawk
      gzip
      gnumake
      watch

      curl
      wget
      openssl
      vim
      htop
      ripgrep
      llvm
      ctags  # Required by neovim plugin tagbar.

      exa
      bat
      file  # Required by gdb-gef.
      bintools-unwrapped  # Required by gdb-gef.
      unzip
      rar
      urlscan  # Required by neomutt.

      kubectl
      kubectx
      kubernetes-helm
      minikube
      kind
      k9s
      stern
      mosh
      terraform
      ansible
      sops
      awscli2
      azure-cli
      doctl

      dnsutils
      inetutils
      jq
      yq
      gettext
      _1password

      rustup
      (python3.withPackages(ps: with ps; [
        pip  # Required by Binary Ninja settings.json NixOS+MacOS Python path compatibility.
        goobook

        ROPGadget

        # Required by gdb-gef.
        capstone
        keystone-engine
        unicorn
        # ropper  # XXX: Marked as broken.
      ]))
      nodejs
      lessc
    ];

    # User scripts are activated by `nixos-rebuild boot` upon reboot covering nixos-install and during `nixos|darwin-rebuild switch`.
    home.activation = {
      userscripts = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD $HOME/ops/nix-config/scripts/kciredor/yubikey.sh $VERBOSE_ARG
        $DRY_RUN_CMD $HOME/ops/nix-config/scripts/kciredor/symlinks.sh $VERBOSE_ARG
        $DRY_RUN_CMD $HOME/ops/nix-config/scripts/kciredor/initapps.sh $VERBOSE_ARG
        $DRY_RUN_CMD $HOME/ops/nix-config/scripts/kciredor/linux.sh $VERBOSE_ARG
      '';
    };

    # Allows for integrations like starship when dropping to nix-shell which does not play nice with fish.
    programs.bash.enable = true;

    # Shared by all shells.
    home.shellAliases = {
      ls      = "exa -g";
      l       = "ls -l";
      la      = "ls -alg";
      lr      = "ls -lRg";
      lt      = "ls --tree";
      lg      = "ls -g --long --git";

      cat     = "bat";

      ".."    = "cd ../";
      "..."   = "cd ../../";
      "...."  = "cd ../../../";
      "....." = "cd ../../../../";

      gss     = "git status -s";
      gco     = "git checkout";
      gp      = "git push";
      gc      = "git commit -v";
      glgg    = "git log --graph";
    };

    programs.fish = {
      enable = true;

      shellInit = ''
        umask 027

        fish_vi_key_bindings

        set -xg fish_greeting
  
        set -xg EDITOR nvim
        set -xg PATH "${homeDir}/bin:$PATH"
      '';
  
      plugins = [
          {
            name = "bass";
            src = pkgs.fetchFromGitHub {
              owner = "edc";
              repo = "bass";
              rev = "2fd3d21";
              sha256 = "0mb01y1d0g8ilsr5m8a71j6xmqlyhf8w4xjf00wkk8k41cz3ypky";
            };
          }
          {
            name = "fish-kubectl-completions";
            src = pkgs.fetchFromGitHub {
              owner = "evanlucas";
              repo = "fish-kubectl-completions";
              rev = "ced6763";
              sha256 = "09qcj82qfs4y4nfwvy90y10xmx6vc9yp33nmyk1mpvx0dx6ri21r";
            };
          }
      ];
    };

    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;

      settings = {
        directory = {
          truncation_length = 0;
          truncate_to_repo = false;
        };

        format = "$directory$character";

        # XXX: Does not filter contents of $format currently, see: https://github.com/starship/starship/issues/4953.
        right_format = "$all";

        git_branch.format = "[$symbol$branch]($style) ";

        kubernetes = {
          disabled = false;
          format = "[$symbol$context( \($namespace\))]($style) ";
        };

        aws = {
          disabled = false;
          style = "blue";
          symbol = "☁️ ";
          format = "[$symbol $region]($style) ";
        };
        azure = {
          disabled = false;
          style = "blue";
          symbol = "☁️ ";
          format = "[$symbol $subscription]($style) ";
        };
        gcloud = {
          disabled = false;
          style = "blue";
          symbol = "☁️ ";
          format = "[$symbol $project]($style) ";
        };

        # Required by tmux config to set 'pane_path' variable with current path without dereferencing symlinks.
        custom.tmux = {
          command = "printf \"\\033]7;$PWD\\033\\\\\"";
          when = "true";
        };
      };
    };

    programs.tmux = {
      enable = true;

      clock24 = true;
      aggressiveResize = true;
      baseIndex = 1;
      historyLimit = 250000;
      escapeTime = 0;
      keyMode = "vi";
      terminal = "screen-256color";

      extraConfig = ''
        setw -g monitor-activity on
        set  -g visual-activity on
        set  -g status-interval 1
        set  -g repeat-time 300
        set  -g mouse on

        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind T setw synchronize-panes

        bind-key "|" split-window -h -c "#{pane_path}"
        bind-key "\\" split-window -fh -c "#{pane_path}"
        bind-key "-" split-window -v -c "#{pane_path}"
        bind-key "_" split-window -fv -c "#{pane_path}"
        bind-key "%" split-window -h -c "#{pane_path}"
        bind-key '"' split-window -v -c "#{pane_path}"
        bind-key "c" new-window -c "#{pane_path}"
      '';

      plugins = with pkgs.tmuxPlugins; [
        sensible
        pain-control
        yank
        urlview

        {
          plugin = power-theme;
          extraConfig = "set -g @tmux_power_theme '#483D8B'";
        }
      ];
    };

    programs.fzf = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };

    programs.autojump = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };

    programs.gpg = {
      enable = true;

      # Defaults are based on drduh's hardened config, only adding what was missing.
      settings = {
        throw-keyids = "";
      };

      # Play nice between agent and totp.
      scdaemonSettings = {
        disable-ccid = true;
      };

      mutableKeys = true;
      mutableTrust = false;
      publicKeys = [
        {
          text = lib.strings.fileContents "${homeDir}/ops/nix-config/includes/kciredor/gpg_pubkey";
          trust = 5;
        }
      ];
    };

    programs.ssh = {
      enable = true;
      forwardAgent = false;
      serverAliveInterval = 120;

      includes = [
        "${homeDir}/ops/nix-config/secrets/kciredor/ssh_hosts"
      ];
    };

    programs.git = {
      enable = true;
 
      userName = "Roderick Schaefer";
      userEmail = "roderick@wehandle.it";
 
      signing = {
        signByDefault = true;
        key = "0x31FDA5E3FE0CB640";
      };
 
      ignores = [ "*~" ];
 
      aliases = {
        cleanup = "!git branch --merged | grep  -v '\\*\\|master\\|develop' | xargs -n 1 git branch -d";
      };

      includes = [
        {
          contents = {
            init = {
              defaultBranch = "master";
            };

            branch = {
              autosetuprebase = "always";
            };

            push = {
              default = "tracking";
            };

            merge = {
              tool = "vimdiff";
            };

            mergetool = {
              keepBackup = false;
              prompt = false;
            };

            credential = {
              helper = "store";
            };
          };
        }
      ];
    };

    programs.neovim = {
      enable = true;
      package = pkgs.neovim-unwrapped;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      extraConfig = builtins.concatStringsSep "\n" [
        (lib.strings.fileContents "${homeDir}/ops/nix-config/dotfiles/kciredor/neovim/base.vim")
        (lib.strings.fileContents "${homeDir}/ops/nix-config/dotfiles/kciredor/neovim/plugins.vim")

        ''
          lua << EOF
          ${lib.strings.fileContents "${homeDir}/ops/nix-config/dotfiles/kciredor/neovim/plugins.lua"}
          ${lib.strings.fileContents "${homeDir}/ops/nix-config/dotfiles/kciredor/neovim/lsp.lua"}
          EOF
        ''
      ];

      extraPackages = with pkgs; [
        tree-sitter

        # LSP.
        nodePackages.pyright
        gopls
        rust-analyzer
      ];

      plugins = with pkgs.vimPlugins;
        let
          vimPluginGit = ref: repo: pkgs.vimUtils.buildVimPluginFrom2Nix {
            pname = "${lib.strings.sanitizeDerivationName repo}";
            version = ref;
            src = builtins.fetchGit {
              url = "https://github.com/${repo}.git";
              ref = ref;
            };
          };

        in [
          # Theme.
          tokyonight-nvim

          # Basics.
          lualine-nvim
          bufferline-nvim
          { plugin = nvim-web-devicons; optional = true; }  # Required by lualine, bufferline and nvim-tree.
          nvim-tree-lua
          fzfWrapper
          fzf-vim
          (vimPluginGit "master" "bfredl/nvim-miniyank")

          # Coding.
          nvim-treesitter.withAllGrammars
          # (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))  # Replaces 'ensure_installed = "maintained"' plugin config.  # XXX: Testen met nvim-treesitter-parsers.c / go / vim / sql / rst / nix / lua / etc. of tree-sitter-grammars.tree-sitter-python etc.
          tagbar
          vim-gitgutter
          vim-fugitive
          vim-go
          rust-vim

          # LSP including completion and snippets.
          nvim-lspconfig
          nvim-cmp
          cmp-nvim-lsp
          cmp_luasnip
          luasnip
          friendly-snippets
        ];
    };

    programs.go = {
      enable = true;
      goPath = ".go";
    };

    programs.alacritty = {
      enable = true;

      settings = {
        font.size = 10;

        window = {
          opacity = 0.9;
        };

        env = {
          # Required by multi monitor setup with different DPI.
          WINIT_X11_SCALE_FACTOR = "1";
        };
      };
    };
  };
}
