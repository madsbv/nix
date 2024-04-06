{
  flake-root,
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
# 5. (OPTIONAL) Set up protonmail-bridge with split addresses and set up the addresses we want here.

# Home-manager has mbsync configuration options under accounts.email.accounts.<name>.mbsync, but I don't see how to keep secrets with that method. programs.mbsync has extraConfig which doesn't work with age.
#
# We can however pass a config file to mbsync via the -c flag. If we only wanted to fetch email on a timer or with imapnotify, we could just do that in nix; but if we want mu4e in emacs to be able to poll for new mail, we can do it by using Nix to define a synchronization script and putting it in the path.
#
# Further, we can pass the maildirBasePath to mbsync by wrapping mbsync in such a way that
#
# TODO: Add either scheduled service or imapnotify, or both.
let
  cfg = config.local.email;
  # TODO: The script currently comes out with name "mbsync", overriding the program itself. How can we avoid that and give the wrapper a separate name?
  mbsync-wc = pkgs.symlinkJoin {
    # mbsync-with-config
    name = "mbsync-wc";
    paths = [ pkgs.isync ];
    # Code for makeBinaryWrapper and wrapProgram: https://github.com/NixOS/nixpkgs/blob/011306aa1d3f219e834e1a396e455084edfbf6de/pkgs/build-support/setup-hooks/make-binary-wrapper/make-binary-wrapper.sh#L58
    buildInputs = [ pkgs.makeBinaryWrapper ];
    # This wrapping does two things: It injects a custom config file path which is otherwise not possible with the age + mbsync combination, and it injects the maildir path by relying on the fact that relative paths in mbsync get resolved relative to the current working directory, and we can set that as desired with wrapProgram.
    postBuild = ''
      wrapProgram $out/bin/mbsync --argv0 "mbsync-wc" --chdir "${cfg.maildir}" --add-flags "-c ${cfg.mbsyncrc}"
    '';
  };
in
{
  options.local.email = {
    enable = lib.mkOption { default = true; };
    maildir = lib.mkOption { default = "~/Maildir"; };
    mbsyncrc = lib.mkOption { default = "~/.config/mbsyncrc"; };
    muhome = lib.mkOption { default = "${config.xdg.cacheHome}/mu"; };
    muAddressArgs = lib.mkOption { default = ""; };
  };
  config = lib.mkIf cfg.enable {
    accounts.email.maildirBasePath = cfg.maildir;
    programs.mu.enable = true;
    # nixpkgs.overlays = [ (self: super: { super.mbsync-wc = mbsync-wc; }) ];
    home = {
      packages = [ mbsync-wc ];

      sessionVariables = {
        MUHOME = cfg.muhome;
        MAILDIR = cfg.maildir;
      };

      # NOTE: This may cause issues depending on how `mu init` works when there's already an existing index.
      activation.muInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -d "${cfg.maildir}" ]; then
          mkdir -p "${cfg.maildir}"
        fi
        cat ${cfg.muAddressArgs} | xargs -I % sh -c '${pkgs.mu}/bin/mu init --maildir "${cfg.maildir}" %'
      '';
    };
  };
}
