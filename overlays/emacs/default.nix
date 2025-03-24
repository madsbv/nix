# See https://nixos.wiki/wiki/Overlays#Adding_patches for instructions
# Source of this no-titlebar patch: https://github.com/railwaycat/homebrew-emacsmacport/blob/4f66bd15e99143b232f5b4943e9c4670c3a30b33/patches/emacs-26.2-rc1-mac-7.5-no-title-bar.patch#L40
#
# We could have overridden emacs29-macport, but this way I get to just configure my emacs installation here and only do updates in one place (say to emacs30).
_final: prev:
let
  my-emacs-generic = prev.emacs.override {
    withSQLite3 = true;
    withWebP = true;
    withImageMagick = true;
    withTreeSitter = true;
    withNativeCompilation = true;
  };
in
{
  my-emacs-mac =
    (prev.emacs29-macport.override {
      withNativeCompilation = true;
      withImageMagick = true;
    }).overrideAttrs
      (attrs: {
        patches = attrs.patches ++ [ ./no-titlebar.patch ];
      });

  my-emacs =
    if prev.stdenv.isDarwin then
      # Standard Emacs (i.e. not emacs-macport, which seems largely unmaintained), with homebrew-emacs-plus patches applied: https://github.com/d12frosted/homebrew-emacs-plus
      (my-emacs-generic.override { withPgtk = true; }).overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          # Fix OS window role so that yabai can pick up Emacs
          (prev.fetchpatch {
            url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/fix-window-role.patch";
            sha256 = "+z/KfsBm1lvZTZNiMbxzXQGRTjkCFO4QPlEK35upjsE=";
          })
          # Add setting to enable rounded window with no decoration (still
          # have to alter default-frame-alist)
          (prev.fetchpatch {
            url = "https://github.com/d12frosted/homebrew-emacs-plus/raw/refs/heads/master/patches/emacs-30/round-undecorated-frame.patch";
            sha256 = "uYIxNTyfbprx5mCqMNFVrBcLeo+8e21qmBE3lpcnd+4=";
          })
          # Make Emacs aware of OS-level light/dark mode
          # https://github.com/d12frosted/homebrew-emacs-plus#system-appearance-change
          (prev.fetchpatch {
            url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-30/system-appearance.patch";
            sha256 = "3QLq91AQ6E921/W9nfDjdOUWR8YVsqBAT/W9c1woqAw=";
          })
        ];
      })
    else
      my-emacs-generic;
}
