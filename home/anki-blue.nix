{ config, pkgs, ... }:
let
  home = config.home.homeDirectory;
  checkout = "${home}/workflow/anki-blue";
  dataDir = "${home}/Library/Application Support/anki-blue";
  port = "8770";

  start = pkgs.writeShellScript "anki-blue-start" ''
    # Publish on the tailnet only (never Funnel). Tailscale remembers this, so
    # failing here (e.g. Tailscale not up yet) is fine once it has succeeded.
    /usr/local/bin/tailscale serve --bg --https=443 http://127.0.0.1:${port} >/dev/null \
      || echo "anki-blue: tailscale serve not configured" >&2

    # Own venv, separate from the dev shell's `.venv`.
    export UV_PYTHON=${pkgs.python3}/bin/python3
    export UV_PYTHON_DOWNLOADS=never
    export UV_PROJECT_ENVIRONMENT="${dataDir}/venv"
    export ANKI_BLUE_PORT=${port}
    exec ${pkgs.uv}/bin/uv run --frozen --no-dev --project "${checkout}" anki-blue serve
  '';
in
{
  # Web front end for Anki, synced through AnkiWeb and reachable only on the
  # tailnet at https://blue.tailf5907c.ts.net. Code lives in ~/workflow/anki-blue.
  launchd.agents.anki-blue = {
    enable = true;
    config = {
      ProgramArguments = [ "${start}" ];
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 30;
      StandardOutPath = "${home}/Library/Logs/anki-blue.log";
      StandardErrorPath = "${home}/Library/Logs/anki-blue.log";
    };
  };
}
