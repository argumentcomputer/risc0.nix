{
  description = "Risc0 Nix Flake";

  nixConfig = {
    extra-substituters = [
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      flake = {
        templates = import ./templates;
      };

      perSystem = {
        system,
        pkgs,
        ...
      }: let
        risc0-toolchain = pkgs.callPackage ./pkgs/risc0-toolchain.nix {};

        risc0Platform =
          pkgs.rustPlatform
          // {
            rustc = risc0-toolchain;
            cargo = risc0-toolchain;
          };

        cargo-risczero = pkgs.callPackage ./pkgs/cargo-risczero.nix {
          rustPlatform = risc0Platform;
        };

        risc0-cpp-toolchain = pkgs.callPackage ./pkgs/risc0-cpp-toolchain.nix {};

        risc0-home = pkgs.callPackage ./pkgs/risc0-home.nix {
          inherit cargo-risczero risc0-cpp-toolchain;
          rust-bin-risc0-latest = risc0-toolchain;
        };
      in {
        packages =
          {
            inherit cargo-risczero risc0-toolchain risc0-home;
          }
          // (
            if builtins.elem system ["x86_64-linux" "aarch64-darwin"]
            then {inherit risc0-cpp-toolchain;}
            else {}
          );

        devShells.default = pkgs.mkShell {
          RISC0_HOME = "${risc0-home}";
          buildInputs = [
            cargo-risczero
            pkgs.gcc
            risc0-toolchain
          ];
        };

        formatter = pkgs.nixfmt-tree;
      };
    };
}
