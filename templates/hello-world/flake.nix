{
  description = "Template Risc0 Nix flake";

  inputs = {
    # Lean + System packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Helper: flake-parts for easier outputs
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Provides the Risc0 Rust toolchain and `cargo-risczero` (which includes `r0vm`)
    risc0 = {
      url = "github:argumentcomputer/risc0.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      flake-parts,
      risc0,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # Systems we want to build for
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      perSystem =
        { system, pkgs, ... }:
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            overlays = [ risc0.overlays.default ];
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              pkg-config
              openssl
              ocl-icd
              gcc
              clang
              rust-analyzer
              cargo-risczero
              rust-bin.risc0.latest
            ];
          };
        };
    };
}
