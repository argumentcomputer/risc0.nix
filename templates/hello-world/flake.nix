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

  outputs = inputs @ {
    nixpkgs,
    flake-parts,
    risc0,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      # Systems we want to build for
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      perSystem = {
        system,
        pkgs,
        ...
      }: {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          overlays = [risc0.overlays.default];
        };

        packages = {
          cargo-r0 = pkgs.cargo-risczero;
          rust-r0 = pkgs.rust-bin.risc0.latest;
          r0-home = pkgs.risc0-home;
          r0-wrapper = pkgs.risc0-toolchain-wrapper;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [risc0.devShells.${system}.default];
          RISC0_HOME = "${pkgs.risc0-home}";
          # The risc0 crate uses this to find the toolchain for guest builds
          RISC0_RUST_TOOLCHAIN_PATH = "${pkgs.risc0-toolchain-wrapper.toolchainPath}";
          packages = with pkgs; [
            pkg-config
            openssl
            ocl-icd
            gcc
            clang
            rust-analyzer
          ];
        };
      };
    };
}
