{ config, pkgs, lib, ... }: {
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
        $DRY_RUN_CMD grep -q $HOME/.nix-profile/bin/zsh /etc/shells || ((echo "$HOME/.nix-profile/bin/zsh" | /usr/bin/sudo /usr/bin/tee -a /etc/shells >/dev/null) && (grep -q $USER /etc/passwd && /usr/bin/sudo /usr/bin/chsh -s $HOME/.nix-profile/bin/zsh $USER))
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
      tldr
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
      kustomize
      minikube
      kind
      k9s
      stern
      terraform
      ansible
      sops
      (python3.withPackages(ps: with ps; [
        pip  # Required by Binary Ninja settings.json NixOS+MacOS Python path compatibility.
        distutils  # Required by ChromeOS VM.
        jupyterlab
      ]))
      uv
      gotools
      delve
      rustup
      ruff
      nodejs
      hugo
      gemini-cli

      # XXX: File issue on Github: on MacOS mistakenly looks for core_ghidra.dylib in /nix/store/xxx-rz-ghidra-0.7.0/lib/plugins/../../.
      (rizin.withPlugins (ps: with ps; [
        jsdec
        rz-ghidra
        sigdb
      ]))
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
      cat     = "bat --theme 'Solarized (light)'";
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

    zsh = {
      enable = true;

      dotDir = "${config.xdg.configHome}/zsh";
      defaultKeymap = "viins";
      autocd = false;
      autosuggestion.enable = true;
      enableVteIntegration = true;
      enableCompletion = true;

      syntaxHighlighting = {
        enable = true;
      };

      history = {
        path = "${config.xdg.configHome}/zsh/zsh_history";
        size = 100000;
        extended = true;
        ignoreAllDups = true;
        share = true;
      };

      initContent = ''
        zstyle ':completion:*' matcher-list 'r:|=*' 'l:|=* r:|=*'
        zstyle ':completion:*' menu select

        umask 027
        export PATH="$HOME/bin:$HOME/.nix-profile/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$PATH"

        # Required by tmux config to set 'pane_path' variable with current path without dereferencing symlinks.
        function _send_cwd_for_tmux {
          [[ ! -v TMUX ]] && return
          printf "\033]7;$PWD\033\\"
        }
        add-zsh-hook precmd _send_cwd_for_tmux
      '';
    };

    starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;

      settings = {
        directory = {
          truncation_length = 0;
          truncate_to_repo = false;
        };

        format = "$directory$character";
        right_format = "$all";

        username.disabled = true;
        hostname.disabled = true;

        git_branch = {
          symbol = "⎇  ";
          format = "[$symbol$branch]($style) ";
        };

        kubernetes = {
          disabled = false;
          format = "[$symbol$context( \($namespace\))]($style) ";
        };

        gcloud = {
          disabled = false;
          style = "blue";
          symbol = "☁ ";
          format = "[$symbol $project]($style) ";
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
        set-option -g default-command $SHELL  # XXX: Latest tmux defaults to sh instead of my shell.

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
      enableZshIntegration = true;
    };

    autojump = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    ssh = {
      enable = true;
      forwardAgent = false;
      serverAliveInterval = 120;
    };

    git = {
      enable = true;

      ignores = [ "*~" ];

      aliases = {
        cleanup = "!git branch --merged | grep  -v '\\*\\|main\\|master' | xargs -n 1 git branch -d";
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
            "credential \"https://*.*.sourcemanager.dev\"" = {
              helper = "gcloud.sh";
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

  home.file.".rizinrc".text = ''
    # Looks.
    e scr.color=3
    e scr.utf8=true
    e scr.utf8.curvy=true
    eco nord

    # Usage.
    e cmd.repeat=true
  '';
}
