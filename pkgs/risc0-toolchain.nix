{
  autoPatchelfHook,
  fetchurl,
  gccForLibs,
  lib,
  stdenv,
}:
let
  version = "1.85.0";
  srcs = {
    x86_64-linux = {
      url = "https://github.com/risc0/rust/releases/download/r0.1.85.0/rust-toolchain-x86_64-unknown-linux-gnu.tar.gz";
      hash = "sha256-B2dOSbN2FbeNL7J2AcUJCSM8IfHxo6koFlgglySnrMs=";
    };
    aarch64-linux = {
      url = "https://github.com/risc0/rust/releases/download/r0.1.85.0/rust-toolchain-aarch64-unknown-linux-gnu.tar.gz";
      hash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";
    };
    x86_64-darwin = {
      url = "https://github.com/risc0/rust/releases/download/r0.1.85.0/rust-toolchain-x86_64-apple-darwin.tar.gz";
      hash = "sha256-CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=";
    };
    aarch64-darwin = {
      url = "https://github.com/risc0/rust/releases/download/r0.1.85.0/rust-toolchain-aarch64-apple-darwin.tar.gz";
      hash = "sha256-DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD=";
    };
  };
  srcData =
    srcs.${stdenv.hostPlatform.system}
      or (throw "RISC Zero Rust not available for platform ${stdenv.hostPlatform.system}");
  rustHostPlatform = stdenv.hostPlatform.rust.rustcTarget;
in
stdenv.mkDerivation {
  pname = "risc0-toolchain";
  inherit version;

  src = fetchurl {
    inherit (srcData) url hash;
  };

  nativeBuildInputs = lib.optionals stdenv.isLinux [
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.isLinux [
    gccForLibs.lib
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
    maintainers = [ ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
