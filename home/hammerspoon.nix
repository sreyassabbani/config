{ config, ... }:
{
  home.file.".hammerspoon/init.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/config/home/hammerspoon/init.lua";

  launchd.agents.hammerspoon = {
    enable = true;
    config = {
      ProgramArguments = [ "/usr/bin/open" "-a" "Hammerspoon" ];
      RunAtLoad = true;
      ProcessType = "Interactive";
    };
  };
}
