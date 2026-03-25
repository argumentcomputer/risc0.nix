{
  description = "Template Risc0 Nix flake";

  inputs = {
    nixpkgs.follows = "risc0/nixpkgs";
    flake-parts.follows = "risc0/flake-parts";

    # Provides the Risc0 Rust toolchain and `cargo-risczero` (which includes `r0vm`)
    risc0 = {
      url = "github:argumentcomputer/risc0.nix";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    flake-parts,
    risc0,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
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
        devShells.default = pkgs.mkShell {
          inputsFrom = [risc0.devShells.${system}.default];
          RISC0_HOME = "${risc0.packages.${system}.risc0-home}";
          packages = with pkgs; [
            rust-analyzer
          ];
        };
      };
    };
}
