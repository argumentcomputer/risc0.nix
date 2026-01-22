{
  lib,
  fetchCrate,
  fetchurl,
  rustPlatform,
  pkg-config,
  openssl,
  nix-update-script,
}:
rustPlatform.buildRustPackage rec {
  pname = "cargo-risczero";
  version = "2.3.1";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-gkuLqZ1vDY3XfOROLEdfcFODmzV6r+mJWF+EauxYpzw=";
  };

  src-recursion-hash = "ba5c4f8fae128d90ba6791d99d1927f2b4f73bad2860a2763d3db9ffa4270476"; # That is from cargoDeps/risc0-circuit-recursion/build.rs

  src-recursion = fetchurl {
    url = "https://risc0-artifacts.s3.us-west-2.amazonaws.com/zkr/${src-recursion-hash}.zip";
    hash = "sha256-ulxPj64SjZC6Z5HZnRkn8rT3O60oYKJ2PT25/6QnBHY="; # This hash should be the same as src-recuresion-hash
  };

  env = {
    RECURSION_SRC_PATH = src-recursion;
  };

  cargoHash = "sha256-4d5ian5U+pEbjPIsO9JO2sShDJrxyAY0KWZxF9ixk5g=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  # The tests require network access which is not available in sandboxed Nix builds.
  doCheck = false;

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Cargo extension to help create, manage, and test RISC Zero projects";
    mainProgram = "cargo-risczero";
    homepage = "https://risczero.com";
    license = with lib.licenses; [asl20];
    maintainers = with lib.maintainers; [cameronfyfe];
  };
}
