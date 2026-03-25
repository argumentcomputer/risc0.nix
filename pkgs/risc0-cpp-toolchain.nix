{
  autoPatchelfHook,
  fetchurl,
  gccForLibs,
  gmp,
  lib,
  libmpc,
  mpfr,
  stdenv,
  zlib,
}: let
  version = "2024.1.5";
  versionTag = "2024.01.05";

  srcData =
    {
      x86_64-linux = {
        url = "https://github.com/risc0/toolchain/releases/download/${versionTag}/riscv32im-linux-x86_64.tar.xz";
        hash = "sha256-zBlJfbX9HM2S+j0xWjPKzUukgPjSGzyE37VJPP1o2g0=";
      };
      aarch64-darwin = {
        url = "https://github.com/risc0/toolchain/releases/download/${versionTag}/riscv32im-osx-arm64.tar.xz";
        hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      };
    }.${
      stdenv.hostPlatform.system
    }
    or (throw "RISC Zero C++ toolchain not available for platform ${stdenv.hostPlatform.system}");
in
  stdenv.mkDerivation {
    pname = "risc0-cpp-toolchain";
    inherit version;

    src = fetchurl {
      inherit (srcData) url hash;
    };

    nativeBuildInputs = lib.optionals stdenv.isLinux [
      autoPatchelfHook
    ];

    buildInputs = lib.optionals stdenv.isLinux [
      gccForLibs.lib
      gmp
      libmpc
      mpfr
      zlib
    ];

    dontStrip = true;

    sourceRoot = ".";

    unpackPhase = ''
      runHook preUnpack
      mkdir -p source
      tar -xJf $src -C source
      runHook postUnpack
    '';

    installPhase = ''
      mkdir -p $out
      cp -r source/* $out/
    '';

    passthru = {
      inherit version;
    };

    meta = with lib; {
      description = "RISC Zero C++ cross-compilation toolchain for riscv32im";
      homepage = "https://risczero.com";
      license = licenses.asl20;
      maintainers = [];
      platforms = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
    };
  }
