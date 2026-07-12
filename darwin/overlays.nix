{
  vscodeExtensionsOverlay,
}:
{ pkgs, inputs, ... }:
let
  unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  musicCliOverlay = final: _prev: {
    music-cli = final.callPackage ../pkgs/music-cli.nix { };
  };
  recordlyOverlay = final: _prev: {
    recordly = final.callPackage ../pkgs/recordly.nix { };
  };
  fastOverlay = final: _prev: {
    fast = unstablePkgs.callPackage ../pkgs/fast.nix { };
  };
in
{
  nixpkgs.overlays = [
    vscodeExtensionsOverlay
    musicCliOverlay
    recordlyOverlay
    fastOverlay
  ];
}
