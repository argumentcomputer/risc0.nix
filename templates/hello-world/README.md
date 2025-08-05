# Risc0 Template

## Nix

Enter a Nix dev shell with `nix develop`

## Docker

Build the Docker image with `docker build . -t risc0-dev`

Run with `docker run risc0-dev`. This will drop you into an Ubuntu dev shell with the Risc0 dependencies installed.

The Docker logic is copied from https://github.com/risc0/risc0/blob/main/risc0/cargo-risczero/docker/Dockerfile.release

## Build

Once the dependencies are set up, run `cargo build` and `cargo run` as normal to generate proofs of the `guest` RISC-V. See the [tutorial](https://dev.risczero.com/api/zkvm/quickstart) and [hello-world example](https://github.com/risc0/risc0/tree/main/examples/hello-world).

