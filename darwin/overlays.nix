{ inputs, ... }:
let
  # Local packages in `pkgs/`; each file is called with `callPackage`.
  local = final: _prev: {
    music-cli = final.callPackage ../pkgs/music-cli.nix { };
    recordly = final.callPackage ../pkgs/recordly.nix { };
    tt = final.callPackage ../pkgs/tt.nix { source = inputs.tt-src; };
  };

  # Packages that need a newer nixpkgs than the system pin.
  unstable =
    final: _prev:
    let
      unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${final.stdenv.hostPlatform.system};
    in
    {
      fast = unstablePkgs.callPackage ../pkgs/fast.nix { };
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
