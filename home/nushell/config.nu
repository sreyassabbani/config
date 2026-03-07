# Load user-scoped Nushell modules managed by Home Manager.
let nu_lib_dir = ($nu.home-path | path join "Library" "Application Support" "nushell" "lib")

source ($nu_lib_dir | path join "path.nu")
source ($nu_lib_dir | path join "prompt.nu")
source ($nu_lib_dir | path join "aliases.nu")
source ($nu_lib_dir | path join "zoxide.nu")
source ($nu_lib_dir | path join "ds.nu")
