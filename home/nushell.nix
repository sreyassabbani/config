{ ... }:
{
  home.file = {
    # Keep Nushell support files under the managed config directory, not in Nix strings.
    "Library/Application Support/nushell/lib/path.nu".source = ./nushell/path.nu;
    "Library/Application Support/nushell/lib/prompt.nu".source = ./nushell/prompt.nu;
    "Library/Application Support/nushell/lib/aliases.nu".source = ./nushell/aliases.nu;
    "Library/Application Support/nushell/lib/zoxide.nu".source = ./nushell/zoxide.nu;
    "Library/Application Support/nushell/lib/ds.nu".source = ./nushell/ds.nu;
    "Library/Application Support/nushell/lib/templates/default/flake.nix".source =
      ./nushell/templates/default/flake.nix;
    "Library/Application Support/nushell/lib/templates/default/.envrc".source =
      ./nushell/templates/default/.envrc;
    "Library/Application Support/nushell/lib/templates/default/.gitignore".source =
      ./nushell/templates/default/.gitignore;
    "Library/Application Support/nushell/lib/templates/default/AGENTS.md".source =
      ./nushell/templates/default/AGENTS.md;
    "Library/Application Support/nushell/lib/templates/python/flake.nix".source =
      ./nushell/templates/python/flake.nix;
    "Library/Application Support/nushell/lib/templates/python/pyproject.toml".source =
      ./nushell/templates/python/pyproject.toml;
    "Library/Application Support/nushell/lib/templates/python/README.md".source =
      ./nushell/templates/python/README.md;
    "Library/Application Support/nushell/lib/templates/python/.envrc".source =
      ./nushell/templates/python/.envrc;
    "Library/Application Support/nushell/lib/templates/python/.gitignore".source =
      ./nushell/templates/python/.gitignore;
    "Library/Application Support/nushell/lib/templates/python/.helix/languages.toml".source =
      ./nushell/templates/python/.helix/languages.toml;
  };

  programs.nushell = {
    enable = true;
    extraConfig = builtins.readFile ./nushell/config.nu;
  };
}
