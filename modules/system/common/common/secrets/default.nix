{
  hostname,
  flake-root,
  pkgs,
  config,
  lib,
  ...
}:
{
  ## How to use agenix-rekey
  # See https://github.com/oddlama/agenix-rekey?tab=readme-ov-file#usage
  # In short: To encrypt new secret, load into a shell with agenix-rekey with
  # `nix shell github:oddlama/agenix-rekey`
  # and run `agenix edit secret.age` to edit or create a secret, or `agenix edit -i plain.text secret.age` to encrypt an existing file. To rekey, run `agenix rekey -a`, where `-a` ensures the new files are added to git.
  # Remember to add all keys and (ENCRYPTED) secrets to git!

  imports = [ ./user.nix ];
  # NOTE: Agenix does not error on build if decryption fails. See launchd service if weirdness occurs.
  age = {
    identityPaths =
      if pkgs.stdenv.isDarwin then
        [
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_rsa_key"
        ]
      else if (config.services.openssh.enable or false) then
        map (e: e.path) (
          lib.filter (e: e.type == "rsa" || e.type == "ed25519") config.services.openssh.hostKeys
        )
      else
        [ ];
    rekey = {
      # Hostkey from /etc/ssh/ssh_host_...
      # Generated with `sudo ssh-keygen -A`
      hostPubkey = flake-root + "/pubkeys/ssh/ssh_host_ed25519_key.pub.${hostname}";
      # NOTE: Yubikeys associated to identities specified in masterIdentities have to be present when editing or creating new secrets with `agenix edit`. However, those files also contain the recipient information for the Yubikey, which is all that's required for encryption. We put the recipient info in the separate file `recipients.pub` and use those as extraEncryptionKeys, which doesn't require the Yubikey to be present for encryption, but still allows for decryption via `age -d -i ${identityfile} secret.age`.
      masterIdentities = [ (flake-root + "/pubkeys/yubikey/age-yubikey-identity-mba.pub") ];
      extraEncryptionPubkeys = [ (flake-root + "/pubkeys/yubikey/recipients.pub") ];
      storageMode = "local";
      localStorageDir = flake-root + "/secrets/rekeyed/${hostname}";
      generatedSecretsDir = flake-root + "/secrets/generated";
      agePlugins = [ pkgs.age-plugin-yubikey ];
    };
    secrets.github-api-key-minimal.rekeyFile = flake-root + "/secrets/other/github-nix-api-access.age";
  };
}
