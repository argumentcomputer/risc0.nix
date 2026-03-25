{
  autoPatchelfHook,
  fetchurl,
  gccForLibs,
  lib,
  stdenv,
  zlib,
}: let
  version = "1.91.1";
  tag = "r0.${version}";

  srcData =
    {
      x86_64-linux = {
        url = "https://github.com/risc0/rust/releases/download/${tag}/rust-toolchain-x86_64-unknown-linux-gnu.tar.gz";
        hash = "sha256-4IKh3ESr3vHZVGApWnAhjrKUq5mbg0Vw7JMtBWQczl0=";
      };
      aarch64-linux = {
        url = "https://github.com/risc0/rust/releases/download/${tag}/rust-toolchain-aarch64-unknown-linux-gnu.tar.gz";
        hash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";
      };
      x86_64-darwin = {
        url = "https://github.com/risc0/rust/releases/download/${tag}/rust-toolchain-x86_64-apple-darwin.tar.gz";
        hash = "sha256-CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=";
      };
      aarch64-darwin = {
        url = "https://github.com/risc0/rust/releases/download/${tag}/rust-toolchain-aarch64-apple-darwin.tar.gz";
        hash = "sha256-DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD=";
      };
    }
    .${
      stdenv.hostPlatform.system
    }
      or (throw "RISC Zero Rust not available for platform ${stdenv.hostPlatform.system}");

  rustHostPlatform = stdenv.hostPlatform.rust.rustcTarget;
in
  stdenv.mkDerivation {
    pname = "risc0-toolchain-bin";
    inherit version;

    src = fetchurl {
      inherit (srcData) url hash;
    };

    nativeBuildInputs = lib.optionals stdenv.isLinux [
      autoPatchelfHook
    ];

    buildInputs = lib.optionals stdenv.isLinux [
      gccForLibs.lib
      zlib
    ];

    dontStrip = true;

    unpackPhase = ''
      runHook preUnpack
      tar -xzf $src
      runHook postUnpack
    '';

    installPhase = ''
      mkdir -p $out
      mv bin lib $out/
    '';

    # Metadata compatible with rust-overlay expectations
    passthru = {
      inherit version;
      isRisc0Toolchain = true;
      rustcVersion = version;
      rustcCommitHash = "risc0-${version}";
      availableComponents = [
        "rustc"
        "cargo"
        "rust-std"
      ];
      rustTargetPlatform = rustHostPlatform;
    };

    meta = with lib; {
      description = "RISC Zero custom Rust toolchain with zkVM target support";
      homepage = "https://risczero.com";
      license = licenses.asl20;
      maintainers = [];
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    };
  }
