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
  version = "3.0.4";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-uIrGulFELt1uy9yknZJgn2SRE6h63KC6Vxnnrq16gRY=";
  };

  src-recursion-hash = "744b999f0a35b3c86753311c7efb2a0054be21727095cf105af6ee7d3f4d8849";

  src-recursion = fetchurl {
    url = "https://risc0-artifacts.s3.us-west-2.amazonaws.com/zkr/${src-recursion-hash}.zip";
    hash = "sha256-dEuZnwo1s8hnUzEcfvsqAFS+IXJwlc8QWvbufT9NiEk=";
  };

  env = {
    RECURSION_SRC_PATH = src-recursion;
  };

  cargoHash = "sha256-VnLoMP8PgO/UKbMExq03EsNFxlWuWj3FD4hYeOXBP9E=";

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
