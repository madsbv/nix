{ user, config, pkgs, agenix, secrets, ... }:

{
  # Path to private key corresponding to the public key used to encrypt agenix secrets
  # See Bitwarden for information about backup of this
  age.identityPaths = [ "/Users/${user}/.ssh/id_agenix" ];

  # Your secrets go here
  #
  # Note: the installWithSecrets command you ran to boostrap the machine actually copies over
  #       a Github key pair. However, if you want to store the keypair in your nix-secrets repo
  #       instead, you can reference the age files and specify the symlink path here. Then add your
  #       public key in shared/files.nix.
  #
  #       If you change the key name, you'll need to update the SSH extraConfig in shared/home-manager.nix
  #       so Github reads it correctly.

  # NOTE: Agenix does not error on nix run .#build if decryption fails.
  age.secrets = {
    # SSH keys. The public keys are stored in modules/shared/files.nix, but can also be generated from the corresponding private keys by running `ssh-keygen -y -f path/to/private-key'.
    "mbv-mba-ssh-key" = {
      symlink = true;
      path = "/Users/${user}/.ssh/id_ed25519";
      file = "${secrets}/mbv-mba-ssh-key.age";
      mode = "600";
      owner = "${user}";
      group = "staff";
    };
    "mbv-mba-agenix-ssh-key" = {
      symlink =
        false; # If stuff breaks, we don't want nix to automatically remove the agenix keyfile, since we'd then have to restore from backup to proceed.
      path = "/Users/${user}/.ssh/id_agenix";
      file = "${secrets}/mbv-mba-agenix-ssh-key.age";
      mode = "600";
      owner = "${user}";
      group = "staff";
    };
  };
}
