# Rex

Home Manager links `init.lua` into `~/.config/rex`; run `rex config reload`
after edits. Client appearance and the startup command are in `darwin/rex.nix`.
The startup command applies to new terminals created by the Mac app; CLI-created
terminals may need an explicit `-- nu`.

Rex stores imported themes in app preferences. To restore the theme on a new
installation, use Settings → Themes → Import and select
`home/rex/catppuccin-frappe.conf`. Rex selects it for dark mode.

Rex does not currently provide Ghostty's global quick terminal. Its padding
setting controls padding color, not the 30-pixel horizontal padding in Ghostty.
