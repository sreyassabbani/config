{
  config,
  lib,
  pkgs,
  ...
}:
{
  xdg.configFile."rex/init.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/config/home/rex/init.lua";

  # Rex stores themes as JSON data in macOS preferences. Merge our theme so
  # other custom themes remain intact; Rex may need a restart to see changes.
  home.activation.rexTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${pkgs.python3}/bin/python3 ${./rex/install-theme.py} ${./rex/catppuccin-frappe.json}
  '';
}
