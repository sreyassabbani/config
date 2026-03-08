def --env ds [kind?: string] {
  let mode = ($kind | default "default")

  if ($mode != "default" and $mode != "dev" and $mode != "python" and $mode != "py") {
    print $"ds: unsupported template '($mode)' (try: ds or ds python)"
    return
  }

  let templates = ($nu.home-path | path join "Library" "Application Support" "nushell" "lib" "templates")

  if ($mode == "default" or $mode == "dev") {
    if ("flake.nix" | path exists) {
      print "ds: flake.nix already exists here (won't overwrite)."
      return
    }

    let template_dir = ($templates | path join "default")
    cp ($template_dir | path join "flake.nix") ./flake.nix
    cp ($template_dir | path join ".envrc") ./.envrc
    cp ($template_dir | path join ".gitignore") ./.gitignore
  } else {
    if (("flake.nix" | path exists) or ("pyproject.toml" | path exists) or (".helix/languages.toml" | path exists)) {
      print "ds: project files already exist here (won't overwrite)."
      return
    }

    let template_dir = ($templates | path join "python")
    cp ($template_dir | path join "flake.nix") ./flake.nix
    cp ($template_dir | path join "pyproject.toml") ./pyproject.toml
    cp ($template_dir | path join "README.md") ./README.md
    cp ($template_dir | path join ".envrc") ./.envrc
    cp ($template_dir | path join ".gitignore") ./.gitignore
    mkdir .helix
    cp ($template_dir | path join ".helix" "languages.toml") ./.helix/languages.toml
  }

  let has_direnv = ((which direnv | length) > 0)
  if not $has_direnv {
    print "ds: direnv not found (install it + set up the shell hook)."
    return
  }

  direnv allow
  print $"ds: ($mode) ready"
}
