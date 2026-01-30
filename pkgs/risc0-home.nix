{
  stdenv,
  cargo-risczero,
  risc0-toolchain,
  risc0-cpp-toolchain,
}:
let
  rustTarget = stdenv.hostPlatform.rust.rustcTarget;
in
  stdenv.mkDerivation {
    name = "risc0-home";
    buildInputs = [
      risc0-toolchain
      cargo-risczero
    ];

    src = ./.;

    buildPhase = ''
      toolchain="$out/toolchains/v${risc0-toolchain.version}-rust-${rustTarget}"
      mkdir -p "$toolchain"
      for d in bin lib; do
        ln -s ${risc0-toolchain}/$d "$toolchain/$d"
      done

      extension="$out/extensions/v${cargo-risczero.version}-cargo-risczero-${rustTarget}"
      mkdir -p "$extension"
      for d in cargo-risczero r0vm; do
        ln -s ${cargo-risczero}/bin/$d "$extension/$d"
      done

      ln -s ${risc0-cpp-toolchain}/riscv32im-linux-x86_64 $out/cpp

      mkdir -p $out/tmp
      touch $out/.rzup

      cp ${./settings.toml} $out/settings.toml
    '';
  }
