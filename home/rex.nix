{ config, ... }:
{
  xdg.configFile."rex/init.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/config/home/rex/init.lua";
}
