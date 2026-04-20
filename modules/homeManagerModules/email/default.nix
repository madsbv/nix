{
  config,
  lib,
  pkgs,
  ...
}:
# 5. (OPTIONAL) Set up protonmail-bridge with split addresses and set up the addresses we want here.
#
# TODO: Add either scheduled service or imapnotify, or both.
let
  cfg = config.local.email;
in
{
  options.local.email = {
    enable = lib.mkEnableOption "Email";
    maildir = lib.mkOption { default = "~/Maildir"; };
    muhome = lib.mkOption { default = "${config.xdg.cacheHome}/mu"; };
    muAddressArgs = lib.mkOption { default = ""; };
    pmbridge-password = lib.mkOption { default = ""; };
  };
  config = lib.mkIf cfg.enable {
    home = {
      sessionVariables = {
        MUHOME = cfg.muhome;
        MAILDIR = cfg.maildir;
      };

      activation.muInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -d "${cfg.maildir}" ]; then
          mkdir -p "${cfg.maildir}"
        fi

        # NOTE: mu init clobbers any existing databases, so we have to guard against that manually.
        if [ ! -d "${cfg.muhome}" ]; then
          cat ${cfg.muAddressArgs} | xargs -I % sh -c '${pkgs.mu}/bin/mu init --maildir "${cfg.maildir}" %'
        fi
      '';
    };

    programs = {
      mbsync.enable = true;
      mu.enable = true;
    };
    services = {
      imapnotify.enable = true;
    };

    accounts.email = {
      # TODO: Add more/new addresses
      maildirBasePath = cfg.maildir;
      accounts."proton" = {
        maildir.path = "Proton";
        address = "mvilladsen@pm.me";
        realName = "Mads Bach Villadsen";
        userName = "mvilladsen@pm.me";
        primary = true;
        aliases = [ ];
        folders = {
          sent = "Sent";
          inbox = "Inbox";
          trash = "Trash";
          drafts = "Drafts";
        };
        imap = {
          # We're using Protonmail Bridge, so everything happens locally
          tls.enable = false;
          # Might need to be 127.0.0.1 hardcoded
          host = "127.0.0.1";
          port = 1143;
        };
        smtp = {
          host = "127.0.0.1";
          port = 1025;
        };
        passwordCommand = "cat ${cfg.pmbridge-password}";
        # NOTE: The home manager mu module is not amenable to keeping secrets, use our own implementation
        mu.enable = false;
        mbsync = {
          enable = true;
          expunge = "both";
          create = "both";
          remove = "both";
          subFolders = "Verbatim";
          patterns = [
            "*"
            "!Recovered Messages"
          ];
          extraConfig = {
            account = {
              AuthMechs = "LOGIN";
            };
            channel = {
              CopyArrivalDate = "yes";
              SyncState = "*";
            };
          };
        };
        imapnotify = {
          enable = true;
          boxes = [ "Inbox" ];
          onNotify = "${pkgs.isync}/bin/mbsync proton";
          onNotifyPost = "${pkgs.mu}/bin/mu index";
        };
      };
    };
  };
}
