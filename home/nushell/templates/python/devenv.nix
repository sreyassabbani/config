{
  config,
  lib,
  pkgs,
  ...
}:
{
  packages = [ pkgs.ruff ];

  languages.python = {
    enable = true;
    lsp.package = pkgs.basedpyright;
    uv.enable = true;
  };

  # Keep uv on the Nix Python and the venv at `.venv`, where plain `uv sync` puts it.
  env = {
    UV_PYTHON_DOWNLOADS = "never";
    UV_PROJECT_ENVIRONMENT = lib.mkForce "${config.devenv.root}/.venv";
  };

  enterShell = ''
    [ -d "$UV_PROJECT_ENVIRONMENT" ] || uv venv --quiet "$UV_PROJECT_ENVIRONMENT"
    . "$UV_PROJECT_ENVIRONMENT/bin/activate"
  '';
}
