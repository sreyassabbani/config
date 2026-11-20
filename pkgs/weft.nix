{
  lib,
  rustPlatform,
  source,
}:

# After pushing ~/workflow/weft to GitHub, refresh and test:
#   nix flake update weft-src
#   nix build .#weft
#   ./result/bin/weft --version
rustPlatform.buildRustPackage {
  pname = "weft";
  version = "0.1.0";
  src = source;
  cargoLock.lockFile = "${source}/Cargo.lock";

  meta = {
    description = "Language server for Obsidian-style Markdown notes";
    license = lib.licenses.mit;
    mainProgram = "weft";
    platforms = lib.platforms.unix;
  };
}
