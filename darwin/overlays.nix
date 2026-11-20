{ inputs, ... }:
let
  # Local packages in `pkgs/`; each file is called with `callPackage`.
  local = final: _prev: {
    music-cli = final.callPackage ../pkgs/music-cli.nix { };
    recordly = final.callPackage ../pkgs/recordly.nix { };
    tt = final.callPackage ../pkgs/tt.nix { source = inputs.tt-src; };
    weft = final.callPackage ../pkgs/weft.nix { source = inputs.weft-src; };
  };

  # Packages that need a newer nixpkgs than the system pin.
  unstable =
    final: _prev:
    let
      unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${final.stdenv.hostPlatform.system};
    in
    {
      fast = unstablePkgs.callPackage ../pkgs/fast.nix { };
      # cachix/devenv#3166 (merged after 2.4.0): `shell-env.sh` glued the first appended
      # export onto `eval "''${shellHook:-}"`, word-splitting values with spaces (e.g. a
      # dotenv `SEC_USER_AGENT`) in `--no-reload` shells. Drop once a release has it.
      devenv = unstablePkgs.devenv.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ../pkgs/devenv-shell-env-newline.patch ];
      });
    };

  flakes = final: _prev: {
    petersen = inputs.petersen.packages.${final.stdenv.hostPlatform.system}.default;
  };
in
{
  nixpkgs.overlays = [
    inputs.nix-vscode-extensions.overlays.default
    local
    unstable
    flakes
  ];
}
