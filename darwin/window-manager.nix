{ ... }:
{
  # services.yabai = {
  #   enable = true;
  #   enableScriptingAddition = false;

  #   config = {
  #     layout = "bsp";
  #     auto_balance = "on";
  #     window_gap = 8;
  #     top_padding = 10;
  #     bottom_padding = 10;
  #     left_padding = 10;
  #     right_padding = 10;
  #   };

  #   extraConfig = ''
  #     yabai -m rule --add app=".*" manage=off
  #     yabai -m rule --add app="^Zen$" manage=on
  #     yabai -m rule --add app="^Ghostty$" manage=off
  #     yabai -m rule --add app="^Obsidian$" manage=on
  #     yabai -m rule --add app="^Anki$" manage=on
  #     yabai -m rule --add app="^ChatGPT Atlas$" manage=on
  #     yabai -m rule --add app="^Notion$" manage=on
  #     yabai -m rule --add app="^Notion Calendar$" manage=on
  #   '';
  # };

  services.skhd = {
    enable = true;

    skhdConfig = ''
      cmd - 0x2B [
        "Ghostty" : /usr/bin/osascript \
          -e 'tell application "Ghostty"' \
          -e 'set cfg to new surface configuration' \
          -e 'set command of cfg to "/etc/profiles/per-user/sreysus/bin/hx /Users/sreysus/nix/home/ghostty.conf"' \
          -e 'new window with configuration cfg' \
          -e 'end tell'
        * ~
      ]

      # # ---------- Focus (keep your existing muscle memory) ----------
      # alt - h : yabai -m window --focus west
      # alt - j : yabai -m window --focus south
      # alt - k : yabai -m window --focus north
      # alt - l : yabai -m window --focus east

      # # ---------- Swap (reorder without changing the BSP structure) ----------
      # alt + shift - h : yabai -m window --swap west
      # alt + shift - j : yabai -m window --swap south
      # alt + shift - k : yabai -m window --swap north
      # alt + shift - l : yabai -m window --swap east

      # # ---------- Warp (move window into that direction in the tree) ----------
      # ctrl + alt - h : yabai -m window --warp west
      # ctrl + alt - j : yabai -m window --warp south
      # ctrl + alt - k : yabai -m window --warp north
      # ctrl + alt - l : yabai -m window --warp east

      # # ---------- Float / Zoom ----------
      # alt - space : yabai -m window --toggle float
      # alt - f     : yabai -m window --toggle zoom-fullscreen

      # # ---------- Space layout hygiene ----------
      # ctrl + alt - b : yabai -m space --balance
      # ctrl + alt - r : yabai -m space --rotate 90
      # ctrl + alt - m : yabai -m space --mirror x-axis

      # # ---------- Resize (nudges; works for tiled and floating in different ways) ----------
      # # Tiled windows: yabai interprets these as changing split ratios.
      # # Floating windows: it resizes the actual frame.
      # # Resize: horizontal
      # ctrl + alt + cmd - h : yabai -m window --resize left:50:0  || yabai -m window --resize right:-50:0
      # ctrl + alt + cmd - l : yabai -m window --resize left:-50:0 || yabai -m window --resize right:50:0

      # # Resize: vertical
      # ctrl + alt + cmd - k : yabai -m window --resize top:0:50    || yabai -m window --resize bottom:0:-50
      # ctrl + alt + cmd - j : yabai -m window --resize top:0:-50   || yabai -m window --resize bottom:0:50

      # # ---------- Quality-of-life toggles ----------
      # ctrl + alt - g : yabai -m space --toggle gap
      # ctrl + alt - p : yabai -m space --toggle padding
    '';
  };
}
