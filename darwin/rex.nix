{ ... }:
{
  # Rex stores these client settings in macOS preferences, not init.lua.
  system.defaults.CustomUserPreferences."com.superlogical.rex" = {
    "Workspace.appearance" = "dark";
    "Workspace.showsWindowOnLaunch" = false;
    "Workspace.terminalFontName" = "GeistMono Nerd Font Mono";
    "Workspace.terminalFontPointSize" = 16;
    "Workspace.terminalCursorStyle" = "bar";
    "Workspace.terminalStartupCommand" = "/etc/profiles/per-user/sreysus/bin/nu";
  };
}
