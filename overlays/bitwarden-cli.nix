# Fixes lack of perl in build, but there's still another build error.
_final: prev: {
  bitwarden-cli = prev.bitwarden-cli.overrideAttrs (attrs: {
    nativeBuildInputs = attrs.nativeBuildInputs ++ [ prev.perl ];
  });
}
