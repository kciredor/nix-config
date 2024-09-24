{ pkgs, lib, config, ... }: { accounts.email = {
    maildirBasePath = ".maildir";

    accounts = {
      gmail = {
        primary = true;
        flavor = "gmail.com";
        address = "roderick@kciredor.com";
        userName = "roderick@kciredor.com";
        realName = "Roderick Schaefer";
        passwordCommand = "/usr/bin/security find-generic-password -w -s neomutt";
        imap = {
          host = "imap.gmail.com";
          tls.enable = true;
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
      };
    };
  };

  programs.mbsync = {
    enable = true;
    extraConfig = ''
      Create Both
      Expunge Both
      SyncState *
    '';
  };
}
