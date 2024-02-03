# See https://nixos.wiki/wiki/Overlays#Adding_patches for instructions
# Source of this no-titlebar patch: https://github.com/railwaycat/homebrew-emacsmacport/blob/4f66bd15e99143b232f5b4943e9c4670c3a30b33/patches/emacs-26.2-rc1-mac-7.5-no-title-bar.patch#L40
#
# We could have overridden emacs29-macport, but this way I get to just configure my emacs installation here and only do updates in one place (say to emacs30).
final: prev: {
  my-emacs-mac = (prev.emacs29-macport.override {
    withNativeCompilation = true;
    withImageMagick = true;
  }).overrideAttrs
    (attrs: { patches = attrs.patches ++ [ ./no-titlebar.patch ]; });
}
