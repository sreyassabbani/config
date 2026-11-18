{ config, ... }:
{
  home.file = {
    # Keep Nushell support files under the managed config directory, not in Nix strings.
    "Library/Application Support/nushell/lib/path.nu".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/config/home/nushell/path.nu";
    "Library/Application Support/nushell/lib/prompt.nu".source = ./nushell/prompt.nu;
    "Library/Application Support/nushell/lib/aliases.nu".source = ./nushell/aliases.nu;
    "Library/Application Support/nushell/lib/zoxide.nu".source = ./nushell/zoxide.nu;
    "Library/Application Support/nushell/lib/ds.nu".source = ./nushell/ds.nu;
  };

  programs.nushell = {
    enable = true;
    extraConfig = builtins.readFile ./nushell/config.nu;
  };
}
