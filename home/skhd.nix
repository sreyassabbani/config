{ config, ... }:
{
  services.skhd.enable = true;

  xdg.configFile."skhd/skhdrc".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/home/skhdrc";
}
