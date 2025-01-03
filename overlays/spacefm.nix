# Patch to fix build failure, tracked here: https://github.com/NixOS/nixpkgs/issues/369353
_final: prev: {
  spacefm = prev.spacefm.overrideAttrs (attrs: {
    patches = attrs.patches ++ [ ./patches/250301_spacefm_gcc14.patch ];
  });
}
