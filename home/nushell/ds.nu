# Start a devenv project here from a shared env in `~/config/envs`:
# `ds` (empty), `ds py`, `ds rs`, `ds js`, or `ds cpp`. Never overwrites existing files.
# The copy carries the shared nixpkgs pin; see `~/config/envs/README.md` for why that matters.
def ds [kind: string = "base"] {
  let name = match $kind {
    "base" => "base"
    "python" | "py" => "python"
    "rust" | "rs" => "rust"
    "js" | "ts" => "js"
    "cpp" | "c++" => "cpp"
    _ => { error make --unspanned { msg: $"ds: unsupported env '($kind)' \(try: ds, ds py, ds rs, ds js, or ds cpp\)" } }
  }

  let files = [devenv.nix devenv.yaml]
  let clashes = ($files | where { path exists })
  if not ($clashes | is-empty) {
    error make --unspanned { msg: $"ds: won't overwrite ($clashes | str join ', ')" }
  }
  let src = ($nu.home-dir | path join "config" "envs" $name)
  for file in $files { cp ($src | path join $file) $file }

  # Language files come from the language's own tool, run with the env's toolchain.
  match $name {
    "python" if not ("pyproject.toml" | path exists) => { devenv --quiet shell -- uv init --quiet }
    "rust" if not ("Cargo.toml" | path exists) => { devenv --quiet shell -- cargo init --quiet }
    _ => {}
  }

  let have = if (".gitignore" | path exists) { open --raw .gitignore | lines } else { [] }
  let missing = ([".devenv*" "devenv.local.nix" "devenv.local.yaml"] | where { $in not-in $have })
  if not ($missing | is-empty) {
    let lead = if ($have | is-empty) or (open --raw .gitignore | str ends-with "\n") { "" } else { "\n" }
    $"($lead)($missing | str join "\n")\n" | save --append .gitignore
  }

  devenv allow
  print $"ds: ($name) ready"
}
