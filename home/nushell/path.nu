$env.config = (($env.config? | default {}) | merge {
  show_banner: false
})

let local_bin = ([$env.HOME ".local" "bin"] | path join)
let base_path = [
  $local_bin
  "/Users/sreysus/.bun/bin"
  "/Users/sreysus/.nix-profile/bin"
  "/nix/var/nix/profiles/default/bin"
  "/opt/homebrew/bin"
  "/opt/homebrew/sbin"
  "/etc/profiles/per-user/sreysus/bin"
  "/run/current-system/sw/bin"
  "/usr/local/bin"
  "/usr/bin"
  "/bin"
  "/usr/sbin"
  "/sbin"
]

$env.PATH = ([$local_bin] ++ ($env.PATH? | default []) ++ $base_path | uniq)
