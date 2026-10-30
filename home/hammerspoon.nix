{ config, ... }:
{
  home.file.".hammerspoon/init.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/config/home/hammerspoon/init.lua";
}
