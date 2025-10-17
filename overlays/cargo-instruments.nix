# TODO: Turn into free-standing package and PR to nixpkgs?
_self: super: with super; {
  cargo-instruments = rustPlatform.buildRustPackage rec {
    pname = "cargo-instruments";
    version = "0.4.10";

    src = fetchCrate {
      inherit pname version;
      hash = "sha256-9qNepo4ygGguTW+ev1gsVXQDKuSTx7218mEZQ4UgQzM=";
    };

    cargoHash = "sha256-R82svOcGv1xhqHYFDY9sqeP5nE9SbpyZJAj6eZB+M+k=";

    nativeBuildInputs = [ pkg-config ];

    buildInputs = [
      libgit2
      openssl
      sccache
      libiconv
      llvmPackages_13.libclang
    ]
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
