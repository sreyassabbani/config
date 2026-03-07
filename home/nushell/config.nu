$env.config = (($env.config? | default {}) | merge {
  show_banner: false
})

let base_path = [
  "/Users/sreysus/.nix-profile/bin"
  "/nix/var/nix/profiles/default/bin"
  "/opt/homebrew/bin"
  "/opt/homebrew/sbin"
  "/etc/profiles/per-user/sreysus/bin"
  "/run/current-system/sw/bin"
  "/usr/local/bin"
  "/usr/bin"
  "/bin"
  "/usr/sbin"
  "/sbin"
]

$env.PATH = (($env.PATH? | default []) ++ $base_path | uniq)

$env.PROMPT_COMMAND = {||
  let current = ($env.PWD | str replace $nu.home-path "~")
  let location = if $current == "~" {
    ""
  } else {
    $"(ansi '#737994')($current)(ansi reset)\n"
  }

  $"\n($location)(ansi '#8caaee')($env.USER)(ansi reset) (ansi '#f4b8e4')[λ](ansi reset) "
}

$env.PROMPT_COMMAND_RIGHT = {|| "" }
$env.PROMPT_INDICATOR = {|| "" }
$env.PROMPT_INDICATOR_VI_INSERT = {|| "" }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "" }
$env.PROMPT_MULTILINE_INDICATOR = {|| "..." }

alias dr = sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ~/nix#sreysus-aarch64-darwin

export-env {
  $env.config = (
    $env.config?
    | default {}
    | upsert hooks { default {} }
    | upsert hooks.env_change { default {} }
    | upsert hooks.env_change.PWD { default [] }
  )

  let zoxide_hooked = (
    $env.config.hooks.env_change.PWD | any { try { get __zoxide_hook } catch { false } }
  )

  if not $zoxide_hooked {
    $env.config.hooks.env_change.PWD = ($env.config.hooks.env_change.PWD | append {
      __zoxide_hook: true,
      code: {|_, dir| zoxide add -- $dir}
    })
  }
}

def --env --wrapped __zoxide_z [...rest: string] {
  let path = match $rest {
    [] => { "~" }
    [ "-" ] => { "-" }
    [ $arg ] if ($arg | path expand | path type) == "dir" => { $arg }
    _ => {
      zoxide query --exclude $env.PWD -- ...$rest | str trim -r -c "\n"
    }
  }

  cd $path
}

def --env --wrapped __zoxide_zi [...rest: string] {
  cd $'(zoxide query --interactive -- ...$rest | str trim -r -c "\n")'
}

alias cd = __zoxide_z
alias cdi = __zoxide_zi
alias z = __zoxide_z
alias zi = __zoxide_zi

def --env ds [] {
  if ("flake.nix" | path exists) {
    print "ds: flake.nix already exists here (won't overwrite)."
    return
  }

  bash -c '
cat > flake.nix <<"EOF"
{
  inputs = {
    # FlakeHub nixpkgs: "0" tracks the current stable nixpkgs channel on FlakeHub
    nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.tar.gz";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nodejs_24
            bun
            # pnpm
            gemini-cli
          ];

          shellHook = "
            echo \"Nix dev shell activated\"
            echo \"Node:  $(node --version 2>/dev/null || echo not-found)\"
            echo \"Bun:   $(bun --version 2>/dev/null || echo not-found)\"
          ";
        };
      }
    );
}
EOF

touch .envrc
grep -qx "use flake" .envrc || printf "%s\n" "use flake" >> .envrc

touch .gitignore
grep -qx "\.direnv" .gitignore || printf "%s\n" ".direnv" >> .gitignore
'

  let has_direnv = ((which direnv | length) > 0)
  if not $has_direnv {
    print "ds: direnv not found (install it + set up the shell hook)."
    return
  }

  direnv allow
  print "ds: done"
}
