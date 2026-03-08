{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;

    # Important: don't use pkgs.ghostty on macOS right now, it's broken.
    package = null;

    # Optional, but safe: avoids bat-syntax issues on mac
    installBatSyntax = false;

    settings = {
      command = "${pkgs.nushell}/bin/nu";
      shell-integration = "none";
      cursor-style = "bar";

      theme = "Catppuccin Frappe";

      window-padding-x = 30;
      # window-padding-y = "40,0"; # if you want this later

      font-size = 16;
      font-family = "GeistMono Nerd Font Mono";

      keybind = [
        "global:cmd+grave_accent=toggle_quick_terminal"
        "global:cmd+shift+grave_accent=new_window"
        "shift+enter=text:\\n"
      ];
    };
  };
}
