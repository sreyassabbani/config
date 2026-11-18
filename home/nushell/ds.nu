# Scaffold a devenv project here from `~/config/home/nushell/templates`:
# `ds` (default), `ds py`, or `ds rs`. Never overwrites existing files.
def ds [kind: string = "default"] {
  let name = match $kind {
    "default" | "dev" => "default"
    "python" | "py" => "python"
    "rust" | "rs" => "rust"
    _ => { error make --unspanned { msg: $"ds: unsupported template '($kind)' \(try: ds, ds py, or ds rs\)" } }
  }

  let src = ($nu.home-dir | path join "config" "home" "nushell" "templates" $name)
  let files = (glob --no-dir ($src | path join "**" "*") | each { path relative-to $src })

  let clashes = ($files | where { path exists })
  if not ($clashes | is-empty) {
    error make --unspanned { msg: $"ds: won't overwrite ($clashes | str join ', ')" }
  }

  for file in $files {
    let dir = ($file | path dirname)
    if $dir != "" { mkdir $dir }
    cp ($src | path join $file) $file
  }

  devenv allow
  print $"ds: ($name) ready"
}
