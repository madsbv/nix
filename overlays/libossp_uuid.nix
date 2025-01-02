# 250101: Fixes build error, provided in: https://github.com/NixOS/nixpkgs/pull/369649
final: prev: {
  libossp_uuid = prev.libossp_uuid.overrideAttrs (attrs: {
    configureFlags =
      prev.lib.optional (prev.stdenv.buildPlatform != prev.stdenv.hostPlatform) "ac_cv_va_copy=C99"
      ++ prev.lib.optional prev.stdenv.hostPlatform.isFreeBSD "--with-pic";
  });
}
