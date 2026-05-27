{
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.tar.gz";
    flake-utils.url = "github:numtide/flake-utils";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, flake-utils, fenix, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ fenix.overlays.default ];
        };

        pinned = pkgs.fenix.stable;
        rust = pinned.withComponents [
          "cargo"
          "rustc"
          "rustfmt"
          "clippy"
          "rust-src"
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            rust
            rust-analyzer-nightly
            bacon
            lldb
          ];

          shellHook = ''
            export RUST_SRC_PATH="${pinned.rust-src}/lib/rustlib/src/rust/library"
          '';
        };
      }
    );
}
