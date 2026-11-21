{
  config,
  lib,
  pkgs,
  ...
}:
let
  # The Hex cask (darwin/homebrew.nix) ships its CLI inside the app bundle.
  bin = "/Applications/Hex.app/Contents/MacOS/hex";

  # Dictation steps and vocabulary live in ./hex and are read from the
  # checkout, so the gitignored people.local.json is seen and edits apply
  # with `hex sync` alone; see hex/sync.nu.
  sync = pkgs.writers.writeNuBin "hex-sync" {
    makeWrapperArgs = [
      "--set"
      "HEX_CONFIG"
      "${config.home.homeDirectory}/config/home/hex"
      "--set"
      "HEX_BIN"
      bin
    ];
  } (builtins.readFile ./hex/sync.nu);

  # `hex` on PATH: `hex sync` runs the sync above, anything else goes to Hex.
  cli = pkgs.writeShellApplication {
    name = "hex";
    text = ''
      if [ "''${1:-}" = sync ]; then
        shift
        exec ${sync}/bin/hex-sync "$@"
      fi
      exec ${bin} "$@"
    '';
  };
in
{
  home.packages = [ cli ];

  # Hex owns its settings file and rewrites it, so push to it rather than
  # linking it. Skipped when Hex isn't running; never fails the switch.
  home.activation.hexSync = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -x ${bin} ]; then
      run ${sync}/bin/hex-sync || echo "hex-sync failed; run \`hex sync\` to retry" >&2
    fi
  '';
}
