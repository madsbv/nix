_: {
  nix.settings = {
    substituters = [
      "https://nix-community.cachix.org/"
      "https://cache.nixos.org/"
      ## ca-derivations cache, seems to be down as of 251013, unable to find confirmation
      # "https://cache.ngi0.nixos.org/"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ## ca-derivations cache, seems to be down as of 251013, unable to find confirmation
      # "cache.ngi0.nixos.org-1:KqH5CBLNSyX184S9BKZJo1LxrxJ9ltnY2uAs5c/f1MA="
    ];
  };
}
