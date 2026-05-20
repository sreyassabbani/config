{
  vscodeExtensionsOverlay,
}:
{ ... }:
let
  musicCliOverlay = final: _prev: {
    music-cli = final.callPackage ../pkgs/music-cli.nix { };
  };
  recordlyOverlay = final: _prev: {
    recordly = final.callPackage ../pkgs/recordly.nix { };
  };
in
{
  nixpkgs.overlays = [
    vscodeExtensionsOverlay
    musicCliOverlay
    recordlyOverlay
  ];
}
