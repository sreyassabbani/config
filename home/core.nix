{ username, ... }:
let
  secretDir = "/Users/${username}/.secrets";
in
{
  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    enableNixpkgsReleaseCheck = false;
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}
