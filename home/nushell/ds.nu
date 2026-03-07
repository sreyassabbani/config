def --env ds [] {
  if ("flake.nix" | path exists) {
    print "ds: flake.nix already exists here (won't overwrite)."
    return
  }

  # Reuse the tracked template instead of embedding a heredoc in the shell function.
  let template = ($nu.home-path | path join "Library" "Application Support" "nushell" "lib" "templates" "dev-flake.nix")
  cp $template ./flake.nix

  touch .envrc
  grep -qx "use flake" .envrc || printf "%s\n" "use flake" >> .envrc

  touch .gitignore
  grep -qx "\.direnv" .gitignore || printf "%s\n" ".direnv" >> .gitignore

  let has_direnv = ((which direnv | length) > 0)
  if not $has_direnv {
    print "ds: direnv not found (install it + set up the shell hook)."
    return
  }

  direnv allow
  print "ds: done"
}
