{
  stdenv,
  cargo-risczero,
  rust-bin-risc0-latest,
}:
# TODO:
# - Add cpp with symlink to toolchain
let
  rustTarget = stdenv.hostPlatform.rust.rustcTarget;
in
stdenv.mkDerivation {
  name = "risc0-home";
  buildInputs = [
    rust-bin-risc0-latest
    cargo-risczero
  ];

  src = ./.;

  buildPhase = ''
    toolchain="$out/toolchains/v${rust-bin-risc0-latest.version}-rust-${rustTarget}"
    mkdir -p "$toolchain"
    for d in bin lib; do
      ln -s ${rust-bin-risc0-latest}/$d "$toolchain/$d"
    done

    extension="$out/extensions/v${cargo-risczero.version}-cargo-risczero-${rustTarget}"
    mkdir -p "$extension"
    for d in cargo-risczero r0vm; do
      ln -s ${cargo-risczero}/bin/$d "$extension/$d"
    done

    mkdir -p $out/tmp
    touch $out/.rzup

    cp ${./settings.toml} $out/settings.toml
  '';
}
