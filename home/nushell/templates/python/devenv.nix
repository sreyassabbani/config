{ pkgs, ... }:
{
  packages = [ pkgs.ruff ];

  languages.python = {
    enable = true;
    lsp.package = pkgs.basedpyright;
    uv.enable = true;
    uv.sync.enable = true;
    venv.enable = true;
    venv.quiet = true;
  };

  env.UV_PYTHON_DOWNLOADS = "never";
}
