{ pkgs, lib, config, ... }:

{
  home-manager = {
    users.kciredor = { pkgs, lib, ... }: {
      accounts.email = {
        maildirBasePath = ".maildir";
  
        accounts = {
          gmail = {
            primary = true;
            flavor = "gmail.com";
            realName = "Roderick Schaefer";
            address = "roderick@wehandle.it";
            userName = "roderick@wehandle.it";
            passwordCommand = "/home/kciredor/ops/nix-config/secrets/kciredor/gmail.sh";
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
          (lib.strings.fileContents "${config.users.users.kciredor.home}/ops/nix-config/dotfiles/kciredor/neomutt/init.muttrc")
          (lib.strings.fileContents "${config.users.users.kciredor.home}/ops/nix-config/dotfiles/kciredor/neomutt/gmail.muttrc")
          (lib.strings.fileContents "${config.users.users.kciredor.home}/ops/nix-config/dotfiles/kciredor/neomutt/monokai.muttrc")
        ];
      };
  
      programs.msmtp.enable = true;
  
      programs.mbsync = {
        enable = true;
        package = pkgs.unstable.isync;  # XXX: Until stable includes an SSL fix. See: https://github.com/NixOS/nixpkgs/pull/203227.
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
    };
  };
}
