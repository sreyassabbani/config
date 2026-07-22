{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;

    # TODO: don't use pkgs.ghostty on macOS right now, it's broken.
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
        "shift+enter=text:\\n"

        # Okay, so I've decided on ctrl being mainly the "Ghostty key"

        "global:ctrl+shift+backquote=toggle_quick_terminal" # cmd+backquote collides on macOS so avoid
        "global:ctrl+alt+backquote=new_window"

        "ctrl+shift+tab=previous_tab"
        "ctrl+tab=next_tab"

        "ctrl+j=goto_split:down"
        "ctrl+k=goto_split:up"
        "ctrl+h=goto_split:left"
        "ctrl+l=goto_split:right"

        # I should use this more because it's really cool.
        # - For example, if I need to see whether a line breaks the 120 ch limit ruler in Helix, I can toggle this
        "ctrl+shift+enter=toggle_split_zoom"
        "cmd+shift+enter=unbind"

        # There are some other split-related keybinds that don't follow this `ctrl` prefix pattern
        # but those can be found by running `ghostty +list-keybinds | rg "split"`

        # The aforementioned exceptions worthy of noting:
        # - cmd+D makes new horizontal splits
        # - cmd+shift+D makes new horizontal splits
        # - cmd+w closes *surfaces*, which effectively is a general term for tabs, splits, and windows
        #   (specifically it refers to a single Ghostty instance)
      ];

    };
  };
}
