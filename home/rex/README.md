# Rex

Home Manager links `init.lua` into `~/.config/rex`; run `rex config reload`
after edits. Client appearance and the startup command are in `darwin/rex.nix`.
The startup command applies to new terminals created by the Mac app; CLI-created
terminals may need an explicit `-- nu`.

Home Manager merges the saved Catppuccin Frappé theme into Rex’s app
preferences and selects it for dark mode, preserving other custom themes.
Restart Rex after activation if the running app does not pick up the change.
The Ghostty-format source is `home/rex/catppuccin-frappe.conf`.

Rex does not currently provide Ghostty's global quick terminal. Its padding
setting controls padding color, not the 30-pixel horizontal padding in Ghostty.
