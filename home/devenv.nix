# devenv: per-project dev environments, activated on `cd` by its shell hook.
# Projects either carry their own `devenv.nix` or are bound to a shared env in
# `~/config/envs` (listed below).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  home = config.home.homeDirectory;
  envs = "${home}/config/envs";

  # Project (relative to $HOME) -> shared env in `envs/`.
  bindings = {
    "workflow/competitive-programming" = "cpp-python";
    "workflow/competitive-programming/advent-of-code" = "rust";
    "workflow/continued-fractions" = "python";
    "workflow/playground" = "cpp-python";
    "workflow/research/noneuclidean-disentanglement" = "python";
    "workflow/weft" = "rust";
  };

  # nixpkgs' devenv doesn't ship its nushell hook, so generate it for autoload.
  nushellHook = pkgs.runCommand "devenv-hook.nu" { } "${lib.getExe pkgs.devenv} hook nu > $out";

  allow = project: env: ''
    if [ -d ${lib.escapeShellArg "${home}/${project}"} ]; then
      (cd ${lib.escapeShellArg "${home}/${project}"} && run ${lib.getExe pkgs.devenv} --from path:${envs}/${env} allow >/dev/null)
    fi
  '';
in
{
  home.packages = [ pkgs.devenv ];

  home.file."Library/Application Support/nushell/autoload/devenv-hook.nu".source = nushellHook;

  # Before zoxide's hook (order 2000) so zoxide stays last.
  programs.zsh.initContent = lib.mkOrder 1500 ''
    eval "$(devenv hook zsh)"
  '';

  home.activation.devenvBindings = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    lib.concatStrings (lib.mapAttrsToList allow bindings)
  );
}
