final: prev:
let
  canon-capt-lbp6300 = prev.canon-capt.overrideAttrs (attrs: {
    pname = "canon-capt";

    patches = (attrs.patches or [ ]) ++ [
      ./patches/register-lbp6300.patch
      ./patches/add-lbp6300-ppd.patch
    ];

    installPhase = attrs.installPhase + ''
      install -D -m 644 ./ppd/CanonLBP-6300-6300dn.ppd $out/share/cups/model/canon/CanonLBP-6300-6300dn.ppd
    '';
  });
in
{
  inherit canon-capt-lbp6300;
  canon-capt = canon-capt-lbp6300;
}
