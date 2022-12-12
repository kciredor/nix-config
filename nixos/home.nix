{
  imports = [
    <home-manager/nixos>
  ];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
  
    users.root = { config, pkgs, lib, ... }: {
      home.stateVersion = "22.11";

      home.activation = {
        userscripts = lib.hm.dag.entryAfter ["writeBoundary"] ''
          $DRY_RUN_CMD /home/kciredor/ops/nixos/config/nixos/scripts/root/borgssh.sh $VERBOSE_ARG
        '';
      };
    };
  
    users.kciredor = { config, pkgs, lib, ... }: {
      home.stateVersion = "22.11";

      home.packages = with pkgs; [
        (nerdfonts.override { fonts = [ "FiraMono" ]; })  # Includes powerline and fontawesome. Required by Starship, i3status-rust, vim-lualine and vim-bufferline.
  
        exa
        bat
        binutils-unwrapped  # Required by gdb-gef.
        file  # Required by gdb-gef.
        unzip
        unrar
        urlscan  # Required by neomutt.
  
        kubectl
        kubectx
        kubernetes-helm
        k9s
        terraform
        awscli
        azure-cli
        dnsutils
        inetutils
        jq
        gnumake
  
        rustup
        (python3.withPackages(ps: with ps; [
          goobook
  
          ROPGadget
  
          # Required by gdb-gef.
          capstone
          keystone-engine
          unicorn
          ropper
        ]))
        gettext
        lessc
  
        libnotify
        xsel  # Required by tmux-yank.
        scrot
        feh
        i3lock-color
        yubioath-desktop
        cider
        unstable.standardnotes
        unstable.ferdium
  
        wineWowPackages.stable
        winetricks
  
        myGhidra
        chromium

        unstable.webex
      ];
  
      # User scripts are activated by `nixos-rebuild boot` upon reboot covering nixos-install and during `nixos-rebuild switch`.
      home.activation = {
        userscripts = lib.hm.dag.entryAfter ["writeBoundary"] ''
          $DRY_RUN_CMD $HOME/ops/nixos/config/nixos/scripts/kciredor/yubikey.sh $VERBOSE_ARG
          $DRY_RUN_CMD $HOME/ops/nixos/config/nixos/scripts/kciredor/symlinks.sh $VERBOSE_ARG
          $DRY_RUN_CMD $HOME/ops/nixos/config/nixos/scripts/kciredor/initapps.sh $VERBOSE_ARG
        '';
      };
  
      # Systemd unit maintenance (sd-switch is the future default).
      systemd.user.startServices = "sd-switch";
  
      # Docking.
      programs.autorandr = {
        enable = true;
  
        hooks.postswitch = {
          "rescale-wallpaper" = "/home/kciredor/.fehbg";
        };
  
        profiles = {
          "laptop" = {
            fingerprint = {
              eDP-1 = "00ffffffffffff000daef21400000000161c0104a51f117802ee95a3544c99260f505400000001010101010101010101010101010101363680a0703820402e1e240035ad10000018000000fe004e3134304843472d4751320a20000000fe00434d4e0a202020202020202020000000fe004e3134304843472d4751320a2000bb";
            };
            config = {
              eDP-1 = {
                enable = true;
                primary = true;
                mode = "1920x1080";
              };
            };
          };
          "home" = {
            fingerprint = {
              eDP-1 = "00ffffffffffff000daef21400000000161c0104a51f117802ee95a3544c99260f505400000001010101010101010101010101010101363680a0703820402e1e240035ad10000018000000fe004e3134304843472d4751320a20000000fe00434d4e0a202020202020202020000000fe004e3134304843472d4751320a2000bb";
              DP-2-8 = "00ffffffffffff0010aca6a04c39413015190104a55021783afd25a2584f9f260d5054a54b00714f81008180a940d1c0010101010101e77c70a0d0a029505020ca041e4f3100001a000000ff0036384d434635354a3041394c0a000000fc0044454c4c205533343135570a20000000fd0030551e5920000a2020202020200173020319f14c9005040302071601141f12132309070783010000023a801871382d40582c25001e4f3100001e584d00b8a1381440942cb5001e4f3100001e9d6770a0d0a0225050205a041e4f3100001a7a3eb85060a02950282068001e4f3100001a565e00a0a0a02950302035001e4f3100001a00000000000000000000000062";
              DP-1 = "00ffffffffffff0010acb8a0534657300f1b0104a53420783a0495a9554d9d26105054a54b00714f8180a940d1c0d100010101010101283c80a070b023403020360006442100001e000000ff00374d543031373444305746530a000000fc0044454c4c2055323431350a2020000000fd00313d1e5311000a202020202020011402031cf14f9005040302071601141f12132021222309070783010000023a801871382d40582c450006442100001e011d8018711c1620582c250006442100009e011d007251d01e206e28550006442100001e8c0ad08a20e02d10103e96000644210000180000000000000000000000000000000000000000000000000000000c";
            };
            config = {
              eDP-1.enable = false;
              DP-2-8 = {
                enable = true;
                primary = true;
                position = "1920x0";
                mode = "3440x1440";
              };
              DP-1 = {
                enable = true;
                position = "0x120";
                mode = "1920x1200";
              };
            };
          };
          # Sometimes after a clean reboot DP-1 and DP-2 are mixed up.
          "home-alt" = {
            fingerprint = {
              eDP-1 = "00ffffffffffff000daef21400000000161c0104a51f117802ee95a3544c99260f505400000001010101010101010101010101010101363680a0703820402e1e240035ad10000018000000fe004e3134304843472d4751320a20000000fe00434d4e0a202020202020202020000000fe004e3134304843472d4751320a2000bb";
              DP-1-8 = "00ffffffffffff0010aca6a04c39413015190104a55021783afd25a2584f9f260d5054a54b00714f81008180a940d1c0010101010101e77c70a0d0a029505020ca041e4f3100001a000000ff0036384d434635354a3041394c0a000000fc0044454c4c205533343135570a20000000fd0030551e5920000a2020202020200173020319f14c9005040302071601141f12132309070783010000023a801871382d40582c25001e4f3100001e584d00b8a1381440942cb5001e4f3100001e9d6770a0d0a0225050205a041e4f3100001a7a3eb85060a02950282068001e4f3100001a565e00a0a0a02950302035001e4f3100001a00000000000000000000000062";
              DP-2 = "00ffffffffffff0010acb8a0534657300f1b0104a53420783a0495a9554d9d26105054a54b00714f8180a940d1c0d100010101010101283c80a070b023403020360006442100001e000000ff00374d543031373444305746530a000000fc0044454c4c2055323431350a2020000000fd00313d1e5311000a202020202020011402031cf14f9005040302071601141f12132021222309070783010000023a801871382d40582c450006442100001e011d8018711c1620582c250006442100009e011d007251d01e206e28550006442100001e8c0ad08a20e02d10103e96000644210000180000000000000000000000000000000000000000000000000000000c";
            };
            config = {
              eDP-1.enable = false;
              DP-1-8 = {
                enable = true;
                primary = true;
                position = "1920x0";
                mode = "3440x1440";
              };
              DP-2 = {
                enable = true;
                position = "0x120";
                mode = "1920x1200";
              };
            };
          };
          "work-denhaag" = {
            fingerprint = {
              eDP-1 = "00ffffffffffff000daef21400000000161c0104a51f117802ee95a3544c99260f505400000001010101010101010101010101010101363680a0703820402e1e240035ad10000018000000fe004e3134304843472d4751320a20000000fe00434d4e0a202020202020202020000000fe004e3134304843472d4751320a2000bb";
              HDMI-1 = "00ffffffffffff00220e6934010101011b1c010380351e782a0565a756529c270f5054a10800d1c081c0a9c0b3009500810081800101023a801871382d40582c45000f282100001e000000fd00323c1e5011000a202020202020000000fc00485020453234330a2020202020000000ff00434e4338323731524e300a202001cd020319b149901f0413031202110167030c0010000022e2002b023a801871382d40582c45000f282100001e023a80d072382d40102c45800f282100001e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001";
            };
            config = {
              eDP-1 = {
                enable = true;
                position = "0x1080";
                mode = "1920x1080";
              };
              HDMI-1 = {
                enable = true;
                primary = true;
                position = "0x0";
                mode = "1920x1080";
              };
            };
          };
          "work-utrecht" = {
            fingerprint = {
              eDP-1 = "00ffffffffffff000daef21400000000161c0104a51f117802ee95a3544c99260f505400000001010101010101010101010101010101363680a0703820402e1e240035ad10000018000000fe004e3134304843472d4751320a20000000fe00434d4e0a202020202020202020000000fe004e3134304843472d4751320a2000bb";
              DP-1 = "00ffffffffffff004c2d250e30335230251d0104a55021783ae345a754529925125054bfef80714f810081c081809500a9c0b3000101e77c70a0d0a0295030203a001d4d3100001a000000fd0032641e9837000a202020202020000000fc00433334483839780a2020202020000000ff0048544f4d3930303230380a202001fe020314f147901f041303125a23090707830100004ed470a0d0a0465030203a001d4d3100001a9d6770a0d0a0225030203a001d4d3100001a565e00a0a0a02950302035001d4d3100001a023a801871382d40582c450000000000001e584d00b8a1381440f82c45001d4d3100001e00000000000000000000000000000000004c";
            };
            config = {
              eDP-1 = {
                enable = true;
                position = "760x1440";
                mode = "1920x1080";
              };
              DP-1 = {
                enable = true;
                primary = true;
                position = "0x0";
                mode = "3440x1440";
              };
            };
          };
        };
      };
  
      fonts.fontconfig.enable = true;
  
      # Allows for integrations like starship when dropping to nix-shell which does not play nice with fish.
      programs.bash.enable = true;
  
      # Shared by all shells.
      home.shellAliases = {
        vinix   = "vim ~/ops/nixos/config/nixos/configuration.nix ~/ops/nixos/config/nixos/home.nix";
        rebuild = "sudo nix-channel --update && sudo nixos-rebuild switch";
  
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
  
        clip    = "xsel -b";
      };
  
      programs.fish = {
        enable = true;
  
        shellInit = ''
          umask 027
  
          fish_vi_key_bindings
  
          set -xg fish_greeting
  
          set -xg EDITOR nvim
          set -xg PATH "/home/kciredor/bin:$PATH"
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
  
      home.file.".gdbinit".text = ''
        set auto-load safe-path /nix/store
  
        source ~/ops/nixos/config/nixos/includes/kciredor/gef.py
      '';
  
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
  
          right_format = lib.concatStrings [
            "$all"
          ];
  
          git_branch.format = "[$symbol$branch]($style) ";
  
          kubernetes = {
            disabled = false;
            format = "[$symbol$context( \($namespace\))]($style) ";
          };
  
          aws.disabled = true;
          gcloud.disabled = true;
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
        tmuxp.enable = true;
  
        extraConfig = ''
          setw -g monitor-activity on
          set  -g visual-activity on
          set  -g status-interval 1
          set  -g repeat-time 300
          set  -g mouse on
  
          bind-key -T copy-mode-vi v send-keys -X begin-selection
          bind T setw synchronize-panes
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
  
        mutableKeys = false;
        mutableTrust = false;
        publicKeys = [
          {
            source = ./includes/kciredor/gpg_pubkey;
            trust = 5;
          }
        ];
      };
  
      services.gpg-agent = {
        enable = true;
  
        enableSshSupport = true;
        pinentryFlavor = "gtk2";  # Curses tends to open in the wrong terminal.
      };
  
      programs.ssh = {
        enable = true;
        forwardAgent = false;
        serverAliveInterval = 120;
  
        includes = [
          "${config.home.homeDirectory}/ops/nixos/config/nixos/secrets/kciredor/ssh_hosts"
        ];
      };
  
      services.keybase.enable = true;
  
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
  
        # Added ../../ prefix to paths for initial nixos-install compatibility.
        extraConfig = builtins.concatStringsSep "\n" [
          (lib.strings.fileContents ../../home/kciredor/ops/nixos/config/dotfiles/kciredor/neovim/base.vim)
          (lib.strings.fileContents ../../home/kciredor/ops/nixos/config/dotfiles/kciredor/neovim/plugins.vim)
  
          ''
            lua << EOF
            ${lib.strings.fileContents ../../home/kciredor/ops/nixos/config/dotfiles/kciredor/neovim/plugins.lua}
            ${lib.strings.fileContents ../../home/kciredor/ops/nixos/config/dotfiles/kciredor/neovim/lsp.lua}
            EOF
          ''
        ];
  
        extraPackages = with pkgs; [
          tree-sitter
          ctags  # Required by tagbar.
  
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
            (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))  # Replaces 'ensure_installed = "maintained"' plugin config.
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
  
      accounts.email = {
        maildirBasePath = ".maildir";
  
        accounts = {
          gmail = {
            primary = true;
            flavor = "gmail.com";
            realName = "Roderick Schaefer";
            address = "roderick@wehandle.it";
            userName = "roderick@wehandle.it";
            passwordCommand = "/home/kciredor/ops/nixos/config/nixos/secrets/kciredor/gmail.sh";
            signature = {
              showSignature = "append";
              text = ''
  
  
                Met vriendelijke groet,
                Roderick Schaefer
  
              '';
            };
            gpg = {
              encryptByDefault = false;
              signByDefault = true;
              key = "0x9ECCEBE3D5B38DA6";
            };
            imap = {
              host = "imap.gmail.com";
              tls.enable = true;
            };
            smtp = {
              host = "smtp.gmail.com";
              tls.enable = true;
            };
            msmtp = {
              enable = true;
            };
            mbsync = {
              enable = true;
  
              subFolders  = "Verbatim";
  
              extraConfig = {
                account = {
                  PipelineDepth = 50;
                };
              };
  
              groups.gmail = {
                channels = {
                  default = {
                    patterns = [ "*" "![Gmail]*" "!Archive" "!Sent" "!Flagged" "!Drafts" "!Spam" "!Trash" ];
                  };
                  archive = {
                    farPattern = "[Gmail]/All Mail";
                    nearPattern = "Archive";
                  };
                  sent = {
                    farPattern = "[Gmail]/Sent Mail";
                    nearPattern = "Sent";
                  };
                  flagged = {
                    farPattern = "[Gmail]/Starred";
                    nearPattern = "Flagged";
                  };
                  drafts = {
                    farPattern = "[Gmail]/Drafts";
                    nearPattern = "Drafts";
                  };
                  spam = {
                    farPattern = "[Gmail]/Spam";
                    nearPattern = "Spam";
                  };
                  trash = {
                    farPattern = "[Gmail]/Trash";
                    nearPattern = "Trash";
                  };
                };
              };
            };
            notmuch = {
              enable = true;
            };
            imapnotify = {
              enable = true;
              boxes = [ "Inbox" ];
              extraConfig = {
                wait = 10;
              };
              onNotify = "${pkgs.notmuch}/bin/notmuch new";
              onNotifyPost = "${pkgs.libnotify}/bin/notify-send 'Mail synced'";
            };
            neomutt = {
              enable = true;
              extraMailboxes = [ "Archive" "Sent" "Flagged" "Drafts" "Spam" "Trash" "Kindle" "Later" ];
            };
          };
        };
      };
  
      programs.neomutt = {
        enable = true;
        sidebar.enable = true;
        vimKeys = true;
        checkStatsInterval = 5;
        sort = "reverse-threads";
        binds = [
          { action = "sidebar-next"; key = "<down>";  map = [ "index" "pager" ]; }
          { action = "sidebar-prev"; key = "<up>";    map = [ "index" "pager" ]; }
          { action = "sidebar-open"; key = "<right>"; map = [ "index" "pager" ]; }
        ];
        macros = [
          { action = "<toggle-new>";                     key = "n"; map = [ "index" "pager" ]; }
          { action = "<save-entry><bol>~/down/<eol>";    key = "s"; map = [ "attach" ]; }
          { action = "<shell-escape>notmuch new<enter>"; key = "o"; map = [ "index" ]; }
          { action = "<vfolder-from-query>";             key = "\\\\"; map = [ "index" ]; }
          { action = "<pipe-entry>urlscan<enter>";       key = "U"; map = [ "pager" ]; }
          { action = "<pipe-entry>cat > ~/.cache/neomutt/preview.html && xdg-open ~/.cache/neomutt/preview.html<enter>"; key = "H"; map = [ "attach" ]; }
        ];
        extraConfig = builtins.concatStringsSep "\n" [
          (lib.strings.fileContents ../../home/kciredor/ops/nixos/config/dotfiles/kciredor/neomutt/init.muttrc)
          (lib.strings.fileContents ../../home/kciredor/ops/nixos/config/dotfiles/kciredor/neomutt/gmail.muttrc)
          (lib.strings.fileContents ../../home/kciredor/ops/nixos/config/dotfiles/kciredor/neomutt/monokai.muttrc)
        ];
      };
  
      programs.msmtp.enable = true;
  
      programs.mbsync = {
        enable = true;
        extraConfig = ''
          Create Both
          Expunge Both
          SyncState *
        '';
      };
  
      services.imapnotify.enable = true;
  
      programs.notmuch = {
        enable = true;
        new.tags = [];
        hooks.preNew = "mbsync gmail";
      };
  
      programs.go = {
        enable = true;
        goPath = "dev/go";
        package = pkgs.unstable.go;
      };
  
      # StarBook related, this fixes screen tearing with Intel Iris.
      services.picom = {
        enable = true;
        vSync = true;
        inactiveDim = "0.2";
      };
  
      # Media buttons daemon.
      services.playerctld.enable = true;
  
      xsession.windowManager.i3 = rec {
        enable = true;
  
        config = {
          modifier = "Mod4";
          defaultWorkspace = "workspace number 1";
          terminal = "alacritty";
  
          gaps = {
            inner = 8;
          };
  
          keybindings = pkgs.lib.mkOptionDefault {
            # In case of a xfce+i3 session: xfce4-session-logout.
            "${config.modifier}+Shift+e" = "exec i3-nagbar -t warning -m 'Confirm exit?' -b 'Yes' 'i3-msg exit'";
            "${config.modifier}+F10" = "exec autorandr -c";
            "${config.modifier}+F11" = "exec systemctl suspend-then-hibernate";
            "${config.modifier}+F12" = "exec i3lock-color -i ~/.background-image --ring-color=000000 --keyhl-color ffffff";
  
            "${config.modifier}+h" = "exec i3 workspace previous";
            "${config.modifier}+l" = "exec i3 workspace next";
            "${config.modifier}+t" = "focus next";
            "${config.modifier}+o" = "move window to output right";
            "${config.modifier}+Shift+o" = "move workspace to output right";
            "${config.modifier}+Shift+t" = "move right";
          };
  
          bars = [{
            position  = "top";
            fonts.size = 10.0;
            statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs $HOME/.config/i3status-rust/config-top.toml";
          }];
        };
  
        extraConfig = ''
          # Volume buttons. Alternatively there is sound.mediaKeys.enable.
          bindsym XF86AudioMute        exec --no-startup-id pactl set-sink-mute   @DEFAULT_SINK@ toggle
          bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%
          bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5%
  
          # Media buttons.
          bindsym XF86AudioPlay exec --no-startup-id ${pkgs.playerctl}/bin/playerctl play-pause
          bindsym XF86AudioNext exec --no-startup-id ${pkgs.playerctl}/bin/playerctl next
          bindsym XF86AudioPrev exec --no-startup-id ${pkgs.playerctl}/bin/playerctl previous
  
          # Screenshots.
          bindsym Print                 exec "scrot -m '%Y%m%d_%H%M%S.png' -e 'mv $f ~/images/screenshots/ ; ${pkgs.libnotify}/bin/notify-send Screenshot $f'"
          bindsym --release Shift+Print exec "scrot -s '%Y%m%d_%H%M%S.png' -e 'mv $f ~/images/screenshots/ ; ${pkgs.libnotify}/bin/notify-send Screenshot $f'"
        '';
      };
  
      programs.i3status-rust = {
        enable = true;
  
        bars = {
          top = {
            blocks = [
              {
                block = "load";
                interval = 1;
                format = "{1m}";
              }
              {
                block = "music";
                player = "cider";
                on_collapsed_click = "cider";
                buttons = [ "play" "next" ];
              }
              {
                block = "custom";
                command = "bash -c 'echo -n \" $(dropbox status)\" | head -n 1'";
              }
              {
                block = "custom";
                command = "journalctl -u borgbackup-job-borgbase.service | grep Deactivated | tail -n 1 | awk '{ print \" \" $1 \" \" $2 }'";
                shell = "bash";
              }
              {
                block = "networkmanager";
                on_click = "alacritty -e nmtui";
                device_format = "{icon}{ap}";
                interface_name_include = [ "eth.*" "wlan.*" "vpn.*" ];
              }
              {
                block = "custom";
                command = "echo ";
                on_click = "bash -c 'blueman-manager; pkill blueman-applet; pkill blueman-tray'";
              }
              {
                block = "sound";
                on_click = "pavucontrol";
              }
              {
                block = "battery";
              }
              {
                block = "time";
                interval = 60;
                format = "%a %d/%m %R";
              }
            ];
            theme = "gruvbox-dark";
            icons = "awesome5";
          };
        };
      };
  
      services.screen-locker = {
        enable = true;
  
        inactiveInterval = 10;
        lockCmd = "${pkgs.i3lock-color}/bin/i3lock-color -i ~/.background-image --ring-color=000000 --keyhl-color ffffff";
      };
  
      programs.alacritty = {
        enable = true;
  
        settings = {
          font.size = 10;
  
          key_bindings = [
            { key = "Return"; mods = "Command|Shift"; action = "SpawnNewInstance"; }
          ];
  
          env = {
            # Required by multi monitor setup with different DPI.
            WINIT_X11_SCALE_FACTOR = "1";
          };
        };
      };
  
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
    };
  };
}
