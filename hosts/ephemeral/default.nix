{ mod, pkgs, ... }:

{
  imports = [
    # Generalizable config should be in default.nix, machine-specific stuff should be in configuration.nix and hardware-configuration.nix
    ./configuration.nix
    (mod "shared/keys.nix")
  ];

  local.keys = {
    enable = true;
    enable_authorized_access = true;
    authorized_user = "root";
  };

  # To enable local login, set `users.users.root.initialHashedPassword`
  # You can get the hash of a given password with `mkpasswd -m SHA-512`
  users.mutableUsers = false;

  environment.systemPackages = with pkgs; [
    coreutils
    inetutils
    killall
    fd
    gdu
    ripgrep
    tree
    zellij
  ];

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting = {
        enable = true;
        highlighters = [
          "main"
          "brackets"
        ];
      };
    };
    git.enable = true;
    neovim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
      defaultEditor = true;
    };
  };

  # NOTE: In the committed git history, the file ./tailscale-auth should always be empty.
  # To inject the ephemeral tailscale authentication key at build time, we use a Just recipe to decrypt the key stored in secrets/tailscale, put it in ./tailscale-auth temporarily, build the image, and then clear ./tailscale-auth again.
  # THIS HAS SECURITY IMPLICATIONS.
  # If you try to go through this workflow manually and make a mistake, the tailscale authkey can end up in git. The authkey WILL be stored in the world-readable nix store.
  # This is acceptable to me because an attacker with local storage access can read my host key anyway and decrypt the key directly; and if the authkey gets leaked in git, I can revoke it in the tailscale management console. Furthermore, my Tailscale ACLs are set up to allow machines authenticated with this key to receive connections, but never to establish connections to other machines on my tailnet, so this key does not grant access to any other machines.
  # TODO: Can Disko be used to do this better? See https://github.com/nix-community/disko/blob/master/docs/reference.md
  # There's options to copy files to the VM.
  services = {
    tailscale = {
      enable = true;
      authKeyFile = ./tailscale-auth;
      extraUpFlags = [ "--ssh" ];
    };
    openssh.enable = true;
  };
}
