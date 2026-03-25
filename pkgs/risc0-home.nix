{
  stdenv,
  cargo-risczero,
  risc0-cpp-toolchain,
  rust-bin-risc0-latest,
}: let
  rustTarget = stdenv.hostPlatform.rust.rustcTarget;
  # The cpp toolchain archive extracts to a directory named by the asset,
  # which rzup's find_version_dir resolves as the inner subdir.
  cppAssetName =
    {
      x86_64-linux = "riscv32im-linux-x86_64";
      aarch64-darwin = "riscv32im-osx-arm64";
    }
    .${
      stdenv.hostPlatform.system
    }
      or null;
in
  stdenv.mkDerivation {
    name = "risc0-home";
    buildInputs =
      [
        rust-bin-risc0-latest
        cargo-risczero
      ]
      ++ (
        if cppAssetName != null
        then [risc0-cpp-toolchain]
        else []
      );

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

      ${
        if cppAssetName != null
        then ''
          cpp_toolchain="$out/toolchains/v${risc0-cpp-toolchain.version}-cpp-${rustTarget}"
          mkdir -p "$cpp_toolchain"
          for item in ${risc0-cpp-toolchain}/*; do
            ln -s "$item" "$cpp_toolchain/$(basename $item)"
          done
          ln -s "$cpp_toolchain/${cppAssetName}" "$out/cpp"
        ''
        else ""
      }

      mkdir -p $out/tmp
      touch $out/.rzup

      cp ${./settings.toml} $out/settings.toml
    '';
  }
