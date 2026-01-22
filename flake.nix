{
  description = "Risc0 Nix Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      flake = {
        templates = import ./templates;
      };

      perSystem =
        { system, ... }:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          # The RISC0 Rust toolchain (rustc/cargo with riscv32im-risc0-zkvm-elf target)
          risc0-toolchain = pkgs.callPackage ./pkgs/risc0-toolchain.nix { };

          # rustPlatform using the RISC0 toolchain (for building cargo-risczero)
          risc0Platform = pkgs.rustPlatform // {
            rustc = risc0-toolchain;
            cargo = risc0-toolchain;
          };

          # cargo-risczero CLI tool
          cargo-risczero = pkgs.callPackage ./pkgs/cargo-risczero.nix {
            rustPlatform = risc0Platform;
          };

          # Mimics ~/.risc0 structure for rzup compatibility
          risc0-home = pkgs.callPackage ./pkgs/risc0-home.nix {
            inherit cargo-risczero risc0-toolchain;
          };

        in
        {
          packages = {
            inherit
              cargo-risczero
              risc0-toolchain
              risc0-home
              ;
            default = cargo-risczero;
          };

          devShells = {
            default = pkgs.mkShell {
              RISC0_HOME = "${risc0-home}";
              RISC0_RUST_TOOLCHAIN_PATH = "${risc0-toolchain}";
              buildInputs = [
                cargo-risczero
                pkgs.gcc
              ];
            };
          };

          formatter = pkgs.nixfmt-tree;
        };
    };
}
