{ ... }:
{
  home.file = {
    # Keep Nushell support files under the managed config directory, not in Nix strings.
    "Library/Application Support/nushell/lib/path.nu".source = ./nushell/path.nu;
    "Library/Application Support/nushell/lib/prompt.nu".source = ./nushell/prompt.nu;
    "Library/Application Support/nushell/lib/aliases.nu".source = ./nushell/aliases.nu;
    "Library/Application Support/nushell/lib/zoxide.nu".source = ./nushell/zoxide.nu;
    "Library/Application Support/nushell/lib/ds.nu".source = ./nushell/ds.nu;
    "Library/Application Support/nushell/lib/templates/dev-flake.nix".source =
      ./nushell/templates/dev-flake.nix;
  };

  programs.nushell = {
    enable = true;
    extraConfig = builtins.readFile ./nushell/config.nu;
  };
}
