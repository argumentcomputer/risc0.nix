{
  description = "Risc0 Nix Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{
      self,
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
        overlays.default = import ./overlay.nix;
        templates = import ./templates;
      };

      perSystem =
        {
          system,
          pkgs,
          ...
        }:
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };

          packages = {
            cargo-risczero = pkgs.cargo-risczero;
            rust-bin-risc0-latest = pkgs.rust-bin.risc0.latest;
            risc0-home = pkgs.risc0-home;
          };

          devShells = {
            default = pkgs.callPackage ./shell.nix { };
          };

          formatter = pkgs.nixfmt-tree;

        };
    };
}
