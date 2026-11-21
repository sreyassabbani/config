# weft-sync: commits and pushes the vault, as obsidian-git did, and writes
# daily change lists, as obsidian-list-modified did. home/weft.nix sets
# WEFT_VAULT (the vault) and WEFT_LISTED (the file holding the last day whose
# lists are written) and runs it from launchd; `weft sync` runs it by hand.
#
#   weft-sync        write lists, commit, push; pull only if the push is
#                    rejected (Helix does not reload files changed on disk,
#                    so pulling under an open note is avoided, not handled)
#   weft-sync login  the same, pulling first
#
# Lists are written for finished days only, so today's appear tomorrow and
# the note being written in is never touched.

# Logs the problem, shows it as a notification, and stops.
def fail [message: string] {
  print --stderr $"weft-sync: ($message)"
  try {
    ^/usr/bin/osascript -e 'on run argv' -e 'display notification (item 1 of argv) with title "weft-sync"' -e 'end run' $message
  }
  exit 1
}

def stamp [] {
  date now | format date "%Y-%m-%d %H:%M:%S"
}

# Appends each finished day's change lists to that day's note, from the day
# after the last one written up to yesterday. A note that already has lists
# is left alone.
def write-lists [] {
  let listed = $env.WEFT_LISTED
  let today = date now | format date "%F"
  # The first run starts from today: earlier days are list-modified's.
  if not ($listed | path exists) {
    mkdir ($listed | path dirname)
    (date now) - 1day | format date "%F" | save $listed
    return
  }
  mut day = (open --raw $listed | str trim | into datetime) + 1day | format date "%F"
  while $day < $today {
    let next = ($day | into datetime) + 1day | format date "%F"
    let note = ($day | str replace --all "-" "/") + ".md"
    let has_lists = ($note | path exists) and (open --raw $note | str contains "%% LIST CREATED %%")
    if not $has_lists {
      let lists = (
        ^weft changes $"($day) 00:00" $"($next) 00:00" --into $note
          --exclude "[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9].md"
      )
      if $lists != "" {
        mkdir ($note | path dirname)
        let before = if ($note | path exists) { open --raw $note } else { "" }
        let gap = if $before == "" { "" } else if ($before | str ends-with "\n") { "\n" } else { "\n\n" }
        $gap + ($lists | str trim --right) + "\n" | save --append $note
        print $"wrote change lists into ($note)"
      }
    }
    $day | save --force $listed
    $day = $next
  }
}

def commit [] {
  ^git add -A
  let files = ^git diff --cached --name-only -z | split row (char nul) | where $it != ""
  if ($files | is-empty) { return }
  ^git commit -q -m $"vault backup: (stamp)" -m ("Affected files:\n" + ($files | str join "\n"))
  print $"committed: (^git log -1 --format=%h | str trim)"
}

def pull [] {
  let r = ^git pull -q --no-rebase --no-edit | complete
  if $r.exit_code != 0 {
    print ($r.stdout + $r.stderr | str trim)
    fail "pull did not merge cleanly; resolve the conflict in the vault"
  }
  print "pulled"
}

def push [] {
  if (^git rev-list "@{upstream}..HEAD" | str trim) == "" {
    print "nothing to push"
    return
  }
  let r = ^git push -q | complete
  if $r.exit_code != 0 {
    if not ($r.stderr | str contains "rejected") {
      fail $"push failed: ($r.stderr | str trim)"
    }
    pull
    if (^git push -q | complete).exit_code != 0 { fail "push failed after pulling" }
  }
  print "pushed"
}

def main [mode: string = "sync"] {
  cd $env.WEFT_VAULT
  print $"--- (stamp) ($mode)"

  # Until Obsidian is gone, obsidian-git still syncs while it is open.
  if (^/usr/bin/pgrep -qx Obsidian | complete).exit_code == 0 {
    print "Obsidian is open; leaving sync to obsidian-git"
    return
  }
  let git_dir = ^git rev-parse --git-dir | str trim
  let mid_merge = ["MERGE_HEAD" "rebase-merge" "rebase-apply"] | any {|f| $git_dir | path join $f | path exists }
  if $mid_merge {
    fail "the vault is in the middle of a merge; finish it, then sync resumes"
  }

  write-lists
  commit
  if $mode == "login" { pull }
  push
}
