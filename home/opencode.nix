{ config, ... }:
{
  xdg.configFile."opencode/opencode.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/config/home/opencode.json";
}
