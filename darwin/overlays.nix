{
  vscodeExtensionsOverlay,
  openclawOverlay,
}:
{ ... }:
let
  musicCliOverlay = final: _prev: {
    music-cli = final.callPackage ../pkgs/music-cli.nix { };
  };
in
{
  nixpkgs.overlays = [
    vscodeExtensionsOverlay
    openclawOverlay
    musicCliOverlay
  ];
}
