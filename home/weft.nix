{ config, pkgs, ... }:
let
  home = config.home.homeDirectory;
  vault = "${home}/workflow/thoughts";
  log = "${home}/Library/Logs/weft-sync.log";

  # Commits and pushes the vault, as obsidian-git did. `weft-sync` runs every
  # 30 minutes and pulls only when GitHub rejects the push; `weft-sync login`
  # pulls first. Helix does not reload files changed on disk, so pulling
  # under an open note is avoided rather than handled.
  sync = pkgs.writeShellApplication {
    name = "weft-sync";
    # git and gpg come from Nix; ssh is left to /usr/bin, whose UseKeychain
    # unlocks the GitHub key from launchd.
    runtimeInputs = [
      pkgs.git
      pkgs.coreutils
    ];
    text = ''
      cd ${vault}
      echo "--- $(date '+%Y-%m-%d %H:%M:%S') ''${1:-sync}"

      fail() {
        echo "weft-sync: $1" >&2
        /usr/bin/osascript -e "display notification \"$1\" with title \"weft-sync\"" || true
        exit 1
      }

      # Until Obsidian is gone, obsidian-git still syncs while it is open.
      if /usr/bin/pgrep -qx Obsidian; then
        echo "Obsidian is open; leaving sync to obsidian-git"
        exit 0
      fi
      git_dir=$(git rev-parse --git-dir)
      if [ -e "$git_dir/MERGE_HEAD" ] || [ -d "$git_dir/rebase-merge" ] || [ -d "$git_dir/rebase-apply" ]; then
        fail "the vault is in the middle of a merge; finish it, then sync resumes"
      fi

      commit() {
        git add -A
        # Paths unquoted, as obsidian-git lists them.
        files=$(git diff --cached --name-only -z | tr '\0' '\n')
        [ -n "$files" ] || return 0
        git commit -q -m "vault backup: $(date '+%Y-%m-%d %H:%M:%S')" -m "Affected files:
      $files"
        echo "committed: $(git log -1 --format=%h)"
      }

      pull() {
        git pull -q --no-rebase --no-edit || fail "pull did not merge cleanly; resolve the conflict in the vault"
        echo "pulled"
      }

      commit
      [ "''${1:-}" = login ] && pull
      if [ -z "$(git rev-list '@{upstream}..HEAD')" ]; then
        echo "nothing to push"
        exit 0
      fi
      if ! err=$(git push -q 2>&1); then
        case $err in
          *rejected*) pull; git push -q || fail "push failed after pulling" ;;
          *) fail "push failed: $err" ;;
        esac
      fi
      echo "pushed"
    '';
  };

  agent = args: extra: {
    enable = true;
    config = {
      ProgramArguments = [ "${sync}/bin/weft-sync" ] ++ args;
      StandardOutPath = log;
      StandardErrorPath = log;
    }
    // extra;
  };
in
{
  # weft, the language server for the notes in ~/workflow/thoughts, and the
  # sync that replaced obsidian-git. Source: ~/workflow/weft.
  home.packages = [
    pkgs.weft
    sync
  ];

  programs.helix.languages = {
    language = [
      {
        name = "markdown";
        roots = [
          ".weft"
          ".obsidian"
          ".git"
        ];
        "language-servers" = [ "weft" ];
      }
    ];
    language-server.weft.command = "${pkgs.weft}/bin/weft";
  };

  launchd.agents = {
    weft-sync = agent [ ] { StartInterval = 1800; };
    weft-sync-login = agent [ "login" ] { RunAtLoad = true; };
  };
}
