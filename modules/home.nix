{ pkgs, lib, ... }: {
  imports = [
    ./helix.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
    experimental-features = "nix-command flakes";
  };
  news.display = "silent";

  home = {
    keyboard = {
      options = [
        "caps:swapescape"
      ];
    };

    activation = {
      shell = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD grep -q $HOME/.nix-profile/bin/fish /etc/shells || ((echo "$HOME/.nix-profile/bin/fish" | /usr/bin/sudo /usr/bin/tee -a /etc/shells >/dev/null) && /usr/bin/sudo /usr/bin/chsh -s $HOME/.nix-profile/bin/fish $USER)
      '';
    };

    packages = with pkgs; [
      coreutils
      diffutils
      findutils
      gnused
      gnutar
      gawk
      gzip
      gnumake
      watch

      eza
      bat
      difftastic
      file
      neovim
      curl
      wget
      openssl
      htop
      ripgrep
      dnsutils
      inetutils
      mosh
      unzip
      unrar
      llvm
      gettext
      bintools
      jq
      yq

      (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
      doctl
      kubectl
      kubectx
      kubernetes-helm
      minikube
      kind
      k9s
      stern
      terraform
      ansible
      sops
      (python3.withPackages(ps: with ps; [
        pip  # Required by Binary Ninja settings.json NixOS+MacOS Python path compatibility.
      ]))
      rustup
      nodejs
      hugo
    ];

    # Shared by all shells.
    shellAliases = {
      ls      = "eza -g";
      l       = "eza -gl";
      la      = "eza -gal";
      lr      = "eza -glR";
      lt      = "eza --tree";
      lg      = "eza -g --long --git";

      vi      = "nvim";
      vim     = "nvim";
      vimdiff = "nvim -d";
      cat     = "bat";
      diff    = "difft";

      ".."    = "cd ../";
      "..."   = "cd ../../";
      "...."  = "cd ../../../";

      gss     = "git status -s";
      gco     = "git checkout";
      gp      = "git push";
      gc      = "git commit -v";
      glgg    = "git log --graph";
    };
  };

  programs = {
    home-manager.enable = true;

    # Allows for integrations like starship when dropping to nix-shell which does not play nice with fish.
    bash.enable = true;

    fish = {
      enable = true;

      shellInit = ''
        umask 027

        fish_vi_key_bindings
        set -xg fish_greeting

        set -xg EDITOR hx
        set -xg PATH "$HOME/bin:$HOME/.nix-profile/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$PATH"
      '';

      plugins = [
          {
            name = "bass";
            src = pkgs.fetchFromGitHub {
              owner = "edc";
              repo = "bass";
              rev = "7296c6e";
              sha256 = "sha256-zon5yBcCvL99L2Q5Cf++dfILvkwTezqWpkFUGIoD8Wc=";
            };
          }
          {
            name = "fish-kubectl-completions";
            src = pkgs.fetchFromGitHub {
              owner = "evanlucas";
              repo = "fish-kubectl-completions";
              rev = "ced6763";
              sha256 = "sha256-OYiYTW+g71vD9NWOcX1i2/TaQfAg+c2dJZ5ohwWSDCc=";
            };
          }
      ];
    };

    starship = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;

      settings = {
        directory = {
          truncation_length = 0;
          truncate_to_repo = false;
        };

        format = "$directory$character";
        right_format = "$all";

        git_branch.format = "[$symbol$branch]($style) ";

        kubernetes = {
          disabled = false;
          format = "[$symbol$context( \($namespace\))]($style) ";
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

    tmux = {
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

    fzf = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };

    autojump = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };

    ssh = {
      enable = true;
      forwardAgent = false;
      serverAliveInterval = 120;
    };

    gpg = {
      enable = true;

      # Defaults are based on drduh's hardened config, only adding what was missing.
      settings = {
        throw-keyids = "";
      };

      # Play nice between agent and yubikey totp.
      scdaemonSettings = {
        disable-ccid = true;
      };

      mutableKeys = true;
      mutableTrust = false;
    };

    git = {
      enable = true;

      ignores = [ "*~" ];

      aliases = {
        cleanup = "!git branch --merged | grep  -v '\\*\\|master\\|develop' | xargs -n 1 git branch -d";
      };

      difftastic.enable = true;

      includes = [
        {
          contents = {
            init = {
              defaultBranch = "main";
            };
            branch = {
              autosetuprebase = "always";
            };
            push = {
              default = "tracking";
            };
            merge = {
              tool = "nvimdiff";
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

    go = {
      enable = true;
      goPath = ".go";
    };
  };
}