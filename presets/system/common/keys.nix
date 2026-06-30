{ flake-root, ... }: {
  local.keys = {
    enable = true;
    authorized_user_keys = [
      (builtins.readFile "${flake-root}/pubkeys/ssh/id_ed25519.mbv-mba.mvilladsen.pub")
      (builtins.readFile "${flake-root}/pubkeys/ssh/id_ed25519.mbv-workstation.mvilladsen.pub")
    ];
  };
}
