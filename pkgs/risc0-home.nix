{
  stdenv,
  cargo-risczero,
  rust-bin-risc0-latest,
}:

# TODO:
# - Add cpp, maybe symlink to toolchains/cpp
# - Don't hardcode versions
stdenv.mkDerivation {
  name = "risc0-home";
  buildInputs = [
    rust-bin-risc0-latest
    cargo-risczero
  ];

  src = ./.;

  buildPhase = ''
    toolchain="$out/toolchains/v1.85.0-rust-x86_64-unknown-linux-gnu"
    mkdir -p "$toolchain"
    for d in bin lib; do
      ln -s ${rust-bin-risc0-latest}/$d "$toolchain/$d"
    done

    extension="$out/extensions/v2.3.1-cargo-risczero-x86_64-unknown-linux-gnu"
    mkdir -p "$extension"
    for d in cargo-risczero r0vm; do
      ln -s ${cargo-risczero}/bin/$d "$extension/$d"
    done

    mkdir -p $out/tmp
    touch $out/.rzup

    cp ${./settings.toml} $out/settings.toml
  '';
}
