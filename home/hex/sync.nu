# hex-sync: makes the running Hex match the files in this directory, then
# checks that it took. home/hex.nix sets HEX_CONFIG (this directory in the
# ~/config checkout, so edits apply without a rebuild) and HEX_BIN, and runs
# it on activation; `hex sync` runs it by hand.
#
#   hex-sync           apply the files, then check that Hex kept them
#   hex-sync --check   only check, changing nothing. launchd runs this at
#                      login and daily: Homebrew upgrades Hex during a
#                      rebuild, but the running copy stays the old version
#                      until it restarts, so the activation check comes too
#                      early to see the new one.
#
#   settings.json        applied with `hex settings apply`; settings it doesn't
#                        name keep their values
#   vocabulary.json      shared vocabulary, committed
#   people.local.json    shared vocabulary that stays off GitHub (gitignored)
#
# The vocabulary files are the whole list: a term added in Hex's window and
# missing from both files is removed.
#
# Hex moves fast, so this is also the alarm for config drift. A renamed
# setting fails the apply, but a renamed field inside one (a mode's
# `post_processing`, say) is dropped without a word, so every value is read
# back and compared. Either way the problem is shown as a notification.

# Logs the problem, shows it as a notification, and stops.
def fail [message: string] {
  print --stderr $"hex-sync: ($message)"
  try {
    ^/usr/bin/osascript -e 'on run argv' -e 'display notification (item 1 of argv) with title "hex-sync"' -e 'end run' $message
  }
  exit 1
}

def --wrapped hex [...args: string] {
  let r = (do { ^$env.HEX_BIN ...$args } | complete)
  if $r.exit_code != 0 {
    fail $"`hex ($args | str join ' ')` failed: ($r.stderr | str trim)"
  }
  $r.stdout
}

def read-terms [path: string] {
  if ($path | path exists) { open $path } else { [] }
}

# A term's spellings as Hex keeps them: it drops one that only differs from
# the term in case, and leaves the field out when there are none.
def spellings [t: record] {
  let term = ($t.term | str downcase)
  $t.sounds_like? | default [] | each { str downcase } | where $it != $term | uniq | sort
}

# Paths in `want` that `have` lacks or holds differently. Fields Hex adds on
# its own are fine; ones it dropped or changed are not.
def missing [want: any, have: any, path: string] {
  let wt = ($want | describe | str replace --regex '<.*' '')
  if $wt == "record" {
    if ($have | describe | str starts-with "record") {
      $want | columns | each {|k|
        if $k in ($have | columns) {
          missing ($want | get $k) ($have | get $k) $"($path).($k)"
        } else {
          [$"($path).($k)"]
        }
      } | flatten
    } else { [$path] }
  } else if ($wt in [list table]) {
    if ($have | describe | str replace --regex '<.*' '') in [list table] and ($have | length) == ($want | length) {
      $want | enumerate | each {|e| missing $e.item ($have | get $e.index) $"($path)[($e.index)]" } | flatten
    } else { [$path] }
  } else if $want == $have { [] } else { [$path] }
}

def main [--check] {
  let dir = $env.HEX_CONFIG
  let file = ($dir | path join settings.json)

  let status = (do { ^$env.HEX_BIN status } | complete)
  if $status.exit_code == 3 {
    print "hex-sync: Hex isn't running; nothing synced"
    return
  }

  if not $check {
    hex settings apply $file | ignore
  }

  let settings = (open $file)
  let drift = ($settings | columns | each {|key|
    missing ($settings | get $key) (hex settings get $key | from json) $key
  } | flatten)
  if not ($drift | is-empty) {
    if $check {
      fail $"Hex no longer matches settings.json at ($drift | str join ', '). Run `hex sync`; if that fails too, Hex renamed them."
    }
    fail $"Hex didn't keep ($drift | str join ', '). It may have renamed them; see `hex settings list`."
  }

  let wanted = (
    (read-terms ($dir | path join vocabulary.json))
    | append (read-terms ($dir | path join people.local.json))
    | each {|t| { term: $t.term, sounds_like: ($t.sounds_like? | default []) } }
  )
  let have = (hex vocabulary list --json | from json | get entries)

  if $check {
    let extra = ($have | where term not-in ($wanted | get term) | get term)
    let off = ($wanted | where {|w|
      let m = ($have | where term == $w.term)
      ($m | is-empty) or ((spellings ($m | first)) != (spellings $w))
    } | get term)
    let diff = ($extra | append $off)
    if not ($diff | is-empty) {
      fail $"Hex's vocabulary differs from the files for ($diff | str join ', '). Add new terms to a file, then run `hex sync`."
    }
    print "hex-sync: Hex matches the files"
    return
  }

  mut removed = 0
  for t in $have {
    let match = ($wanted | where term == $t.term)
    let stale = ($match | is-empty) or ((spellings ($match | first)) != (spellings $t))
    if $stale {
      hex vocabulary remove $t.term | ignore
      $removed += 1
    }
  }

  let kept = (hex vocabulary list --json | from json | get entries | get term)
  let added = ($wanted | where term not-in $kept)
  for t in $added {
    if ($t.sounds_like | is-empty) {
      hex vocabulary add $t.term | ignore
    } else {
      hex vocabulary add $t.term --sounds-like ($t.sounds_like | str join ",") | ignore
    }
  }

  let now = (hex vocabulary list --json | from json | get entries)
  let off = ($wanted | where {|w|
    let m = ($now | where term == $w.term)
    ($m | is-empty) or ((spellings ($m | first)) != (spellings $w))
  } | get term)
  if not ($off | is-empty) {
    fail $"vocabulary didn't take for ($off | str join ', ')"
  }

  print $"hex-sync: settings checked; ($wanted | length) vocabulary terms, ($added | length) added, ($removed) removed"
}
