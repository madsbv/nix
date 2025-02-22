{
  pkgs,
  ...
}:

{

  services = {
    # Default port 9091
    transmission = {
      enable = true;
      package = pkgs.transmission_4;
    };
    # See https://www.reddit.com/r/NixOS/comments/12ibbl9/protonvpn_nixos_setup/ for potential protonvpn nixos integration options
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/transmission"
    ];
  };
}
