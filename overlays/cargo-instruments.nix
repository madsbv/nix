# TODO: Turn into free-standing package and PR to nixpkgs?
_self: super:
with super; {
  cargo-instruments = rustPlatform.buildRustPackage rec {
    pname = "cargo-instruments";
    version = "0.4.9";

    src = fetchCrate {
      inherit pname version;
      hash = "sha256-LR8p6N3YUfzRzNMmk9tQbPsTA8PpgnT7Q0r9+lCFgOM=";
    };

    cargoHash = "sha256-D4ZWhcnZaJh+VXI8npGrl3gUcrpPkKWMzXGNBYZ4DRY=";

    nativeBuildInputs = [ pkg-config ];

    buildInputs = [ libgit2 openssl sccache libiconv llvmPackages_13.libclang ]
      ++ lib.optionals stdenv.isDarwin [
        darwin.apple_sdk.frameworks.SystemConfiguration
        darwin.apple_sdk.frameworks.CoreServices
      ];

    meta = with lib; {
      description = "Easily profile your rust crate with Xcode Instruments.";
      homepage = "https://github.com/cmyr/cargo-instruments";
      license = with licenses; [ mit ];
      platforms = platforms.darwin;
    };
  };
}
