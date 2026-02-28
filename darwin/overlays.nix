{
  vscodeExtensionsOverlay,
  openclawOverlay,
}:
{ ... }:
{
  nixpkgs.overlays = [
    vscodeExtensionsOverlay
    openclawOverlay
  ];
}
