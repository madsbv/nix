{ flake-root, user, lib, config, pkgs, secrets, ... }: {
  # Path to private key corresponding to the public key used to encrypt agenix secrets
  # See Bitwarden for information about backup of this
  # age.identityPaths = [ "/Users/${user}/.ssh/id_agenix" ];

  # TODO: We can probably move this to a more general location (flake.nix?)
  age.rekey = {
    # Hostkey from /etc/ssh/ssh_host_...
    # Generated with `sudo ssh-keygen -A`
    hostPubkey = flake-root
      + "/pubkeys/hosts/${config.networking.hostName}.pub";
    # NOTE: Yubikeys associated to identities specified in masterIdentities have to be present when editing or creating new secrets with `agenix edit` (to create secret from existing file, use `agenix edit -i original.txt original.age`). However, those files also contain the recipient information for the yubikey, which is all that's required for encryption. We put the recipient info in the separate file `recipients.pub` and use those as extraEncryptionKeys, which doesn't require the yubikey to be present for encryption, but still allows for decryption via `age -d -i ${identityfile} secret.age`.
    masterIdentities =
      [ (flake-root + "/pubkeys/yubikey/age-yubikey-identity-mba.pub") ];
    extraEncryptionPubkeys =
      [ (flake-root + "/pubkeys/yubikey/recipients.pub") ];
    storageMode = "local";
    localStorageDir = flake-root
      + "/secrets/rekeyed/${config.networking.hostName}";
    generatedSecretsDir = flake-root + "/secrets/generated";
    agePlugins = [ pkgs.age-plugin-yubikey ];
  };
  age.secrets = {
    "id_ed25519-${config.networking.hostName}" = {
      rekeyFile = flake-root
        + "/secrets/id_ed25519-${config.networking.hostName}.age";
      owner = user;
    };
  };
  # programs.ssh =
  #   let ssh-identity-file = config.age.secrets."id_ed25519-mbv-mba".path;
  #   in { extraConfig = "IdentityFile ${ssh-identity-file}"; };

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
  # age.secrets = {
  #   # SSH keys. The public keys are stored in modules/shared/files.nix, but can also be generated from the corresponding private keys by running `ssh-keygen -y -f path/to/private-key'.
  #   "mbv-mba-ssh-key" = {
  #     symlink = true;
  #     path = "/Users/${user}/.ssh/id_ed25519";
  #     file = "${secrets}/mbv-mba-ssh-key.age";
  #     mode = "600";
  #     owner = "${user}";
  #     group = "staff";
  #   };
  #   "mbv-mba-agenix-ssh-key" = {
  #     symlink =
  #       false; # If stuff breaks, we don't want nix to automatically remove the agenix keyfile, since we'd then have to restore from backup to proceed.
  #     path = "/Users/${user}/.ssh/id_agenix";
  #     file = "${secrets}/mbv-mba-agenix-ssh-key.age";
  #     mode = "600";
  #     owner = "${user}";
  #     group = "staff";
  #   };
  # };
}
