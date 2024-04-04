_final: prev: {
  xdg-user-dirs = prev.xdg-user-dirs.overrideAttrs (attrs: {
    # Patch to xdg-user-dirs (pulled in by xdg-utils and transitively by e.g. alacritty) to compile on darwin
    # https://github.com/NixOS/nixpkgs/commit/28bd8790ade0c8efaa85b022e5ab28ed66cf66ec
    meta = {
      platforms = prev.lib.platforms.unix;
    };
    nativeBuildInputs =
      attrs.nativeBuildInputs
      ++ prev.lib.optionals prev.stdenv.isDarwin [ prev.gettext ];
    buildInputs = prev.lib.optionals prev.stdenv.isDarwin [ prev.libiconv ];
  });
}
