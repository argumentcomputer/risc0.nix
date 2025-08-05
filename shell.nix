# A dev environment for devs *using* risc0 to build and run host+guest pairs.
{
  cargo-risczero,
  gcc,
  mkShell,
  rust-bin,
  risc0-home,
}:
mkShell {
  RISC0_HOME = "${risc0-home}";
  buildInputs = [
    cargo-risczero
    gcc
    rust-bin.risc0.latest
  ];
}
