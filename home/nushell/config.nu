# Load user-scoped Nushell modules managed by Home Manager.
source "~/Library/Application Support/nushell/lib/path.nu"
source "~/Library/Application Support/nushell/lib/prompt.nu"
source "~/Library/Application Support/nushell/lib/aliases.nu"
source "~/Library/Application Support/nushell/lib/zoxide.nu"
source "~/Library/Application Support/nushell/lib/ds.nu"

use std/config dark-theme

$env.config = (($env.config? | default {}) | merge {
  show_banner: false
  highlight_resolved_externals: true
  color_config: (dark-theme)
})
