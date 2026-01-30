{
  autoPatchelfHook,
  fetchurl,
  stdenv,
  lib,
  zlib,
  libmpc,
  mpfr,
  gmp,
}: let
  version = "2024.01.05";
in
  stdenv.mkDerivation {
    pname = "risc0-toolchain";
    inherit version;

    src = fetchurl {
      url = "https://github.com/risc0/toolchain/releases/download/${version}/riscv32im-linux-x86_64.tar.xz";
      sha256 = "sha256-zBlJfbX9HM2S+j0xWjPKzUukgPjSGzyE37VJPP1o2g0=";
    };

    nativeBuildInputs = lib.optionals stdenv.isLinux [
      autoPatchelfHook
    ];

    buildInputs = [
      stdenv.cc.cc.lib
      zlib
      libmpc
      mpfr
      gmp
    ];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r riscv32im-linux-x86_64 $out
      runHook postInstall
    '';
  }
