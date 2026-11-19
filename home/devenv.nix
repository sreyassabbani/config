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

  # Hook shells skip hot-reload: its PTY wrapper adds the `devenv watching N files` bar,
  # and hiding only the bar (`tui.statusline.enabled: false`) makes nushell redraw the
  # prompt on a new line per keystroke once it reaches the bottom row (devenv 2.4.0).
  # After editing `devenv.nix`, `exit` and `cd` back in.
  hookArgs = "-- --no-reload";

  # nixpkgs' devenv doesn't ship its nushell hook, so generate it for autoload.
  nushellHook = pkgs.runCommand "devenv-hook.nu" { } "${lib.getExe pkgs.devenv} hook nu ${hookArgs} > $out";

  allow = project: env: ''
    if [ -d ${lib.escapeShellArg "${home}/${project}"} ]; then
      (cd ${lib.escapeShellArg "${home}/${project}"} && run ${lib.getExe pkgs.devenv} --from path:${envs}/${env} allow >/dev/null)
    fi
  '';
in
{
  home.packages = [ pkgs.devenv ];

  home.file = {
    "Library/Application Support/nushell/autoload/devenv-hook.nu".source = nushellHook;

    # The hook's `devenv shell` starts nu with its own config, which sources the user's
    # from `~/.config/nushell`; ours lives in Application Support (macOS default).
    ".config/nushell/config.nu".source =
      config.lib.file.mkOutOfStoreSymlink "${home}/Library/Application Support/nushell/config.nu";
    ".config/nushell/env.nu".source =
      config.lib.file.mkOutOfStoreSymlink "${home}/Library/Application Support/nushell/env.nu";
  };

  # Drop the `(devenv) ` prefix; `nushell/prompt.nu` marks devenv shells itself.
  xdg.configFile."devenv/config.yaml".text = ''
    version: 1
    shell:
      prompt_prefix: false
  '';

  # Before zoxide's hook (order 2000) so zoxide stays last.
  programs.zsh.initContent = lib.mkOrder 1500 ''
    eval "$(devenv hook zsh ${hookArgs})"
  '';

  home.activation.devenvBindings = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    lib.concatStrings (lib.mapAttrsToList allow bindings)
  );
}
