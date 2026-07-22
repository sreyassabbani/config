{ config, ... }:
{
  programs.ghostty = {
    enable = true;

    # TODO: don't use pkgs.ghostty on macOS right now, it's broken.
    package = null;

    # Optional, but safe: avoids bat-syntax issues on mac
    installBatSyntax = false;
  };

  xdg.configFile."ghostty/config".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/home/ghostty.conf";
}
