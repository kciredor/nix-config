{ pkgs, lib, config, ... }:

{
  home-manager = {
    users.kciredor = { pkgs, lib, ... }: {
      home.packages = with pkgs; [
        html2text
      ];

      accounts.email = {
        maildirBasePath = ".maildir";

        accounts = {
          gmail = {
            primary = true;
            flavor = "gmail.com";
            realName = "Roderick Schaefer";
            address = "roderick@wehandle.it";
            userName = "roderick@wehandle.it";
            passwordCommand = "$HOME/ops/nix-config/secrets/kciredor/gmail.sh";
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
            neomutt = {
              enable = true;
              extraMailboxes = [ "Archive" "Sent" "Flagged" "Drafts" "Spam" "Trash" ];
            };
          };
        };
      };
  
      programs.neomutt = {
        enable = false;  # XXX: Broken on MacOS. See: https://github.com/search?q=repo%3ANixOS%2Fnixpkgs+neomutt&type=issues.
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
          { action = "<pipe-entry>cat > ~/.cache/neomutt/preview.html && open ~/.cache/neomutt/preview.html<enter>"; key = "H"; map = [ "attach" ]; }
        ];
        extraConfig = builtins.concatStringsSep "\n" [
          (lib.strings.fileContents "${config.users.users.kciredor.home}/ops/nix-config/dotfiles/kciredor/neomutt/init.muttrc")
          (lib.strings.fileContents "${config.users.users.kciredor.home}/ops/nix-config/dotfiles/kciredor/neomutt/gmail.muttrc")
          (lib.strings.fileContents "${config.users.users.kciredor.home}/ops/nix-config/dotfiles/kciredor/neomutt/monokai.muttrc")
        ];
      };

      home.file.".mailcap".text = ''
        text/html; html2text %s | less
        application/pdf; open %s
        image/*; open %s
        audio/*; open %s
        video/*; open %s
      '';
  
      programs.msmtp.enable = true;
  
      programs.mbsync = {
        enable = true;
        extraConfig = ''
          Create Both
          Expunge Both
          SyncState *
        '';
      };
  
      programs.notmuch = {
        enable = true;
        new.tags = [];
        hooks.preNew = "mbsync gmail";
      };

      # Interval sync because imapnotify on macOS has no service support and on macOS mbsync is slow.
      home.file."Library/LaunchAgents/com.notmuch.plist".text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>com.notmuch</string>
            <key>ProgramArguments</key>
            <array>
                <string>/etc/profiles/per-user/kciredor/bin/notmuch</string>
                <string>new</string>
            </array>
            <key>StartInterval</key>
            <integer>900</integer>
            <key>EnvironmentVariables</key>
            <dict>
                <key>PATH</key>
                <string>/etc/profiles/per-user/kciredor/bin</string>
            </dict>
        </dict>
        </plist>
      '';
    };
  };
}
