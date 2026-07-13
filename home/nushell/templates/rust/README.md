# app

## Setup

Choose either setup path:

- With Nix and `direnv`: run `direnv allow`. You can use `nix develop` instead if you do
  not want the automatic directory hook.
- Without Nix: install Rust with [`rustup`](https://rustup.rs/), then run
  `rustup component add clippy rust-analyzer rust-src rustfmt`.

After setup, the Cargo commands below work on macOS, Linux, and Windows. The Nix shell
also provides optional tools such as `bacon` and LLDB, but they are not required to build
the project.

## Rust deps

This project uses Cargo.

- Add dependencies with `cargo add <crate>`
- Check the project with `cargo check`
- Run the project with `cargo run`

Commit `Cargo.lock` for applications so Nix and non-Nix contributors resolve the same crates.
