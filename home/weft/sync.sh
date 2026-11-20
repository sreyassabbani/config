# weft-sync: commits and pushes the vault, as obsidian-git did, and writes
# daily change lists, as obsidian-list-modified did. home/weft.nix sets
# WEFT_VAULT (the vault) and WEFT_LISTED (the last day whose lists are
# written) and runs it from launchd; `weft sync` runs it by hand.
#
#   weft-sync        write lists, commit, push; pull only if the push is
#                    rejected (Helix does not reload files changed on disk,
#                    so pulling under an open note is avoided, not handled)
#   weft-sync login  the same, pulling first
#
# Lists are written for finished days only, so today's appear tomorrow and
# the note being written in is never touched.

cd "$WEFT_VAULT"
listed=$WEFT_LISTED
echo "--- $(date '+%Y-%m-%d %H:%M:%S') ${1:-sync}"

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

write_lists() {
  # The first run starts from today: earlier days are list-modified's.
  if [ ! -f "$listed" ]; then
    mkdir -p "$(dirname "$listed")"
    date -d yesterday +%F >"$listed"
    return
  fi
  local day next note lists
  day=$(date -d "$(cat "$listed") + 1 day" +%F)
  while [[ $day < $(date +%F) ]]; do
    next=$(date -d "$day + 1 day" +%F)
    note=$(date -d "$day" +%Y/%m/%d).md
    if ! grep -qsF '%% LIST CREATED %%' "$note"; then
      lists=$(weft changes "$day 00:00" "$next 00:00" --into "$note" \
        --exclude '[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9].md')
      if [ -n "$lists" ]; then
        mkdir -p "$(dirname "$note")"
        if [ -s "$note" ]; then
          [ -z "$(tail -c1 "$note")" ] || echo >>"$note"
          echo >>"$note"
        fi
        printf '%s\n' "$lists" >>"$note"
        echo "wrote change lists into $note"
      fi
    fi
    echo "$day" >"$listed"
    day=$next
  done
}

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

write_lists
commit
[ "${1:-}" = login ] && pull
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
