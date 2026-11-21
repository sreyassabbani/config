# hex-sync: makes the running Hex match the files in this directory.
# home/hex.nix sets HEX_CONFIG (this directory in the ~/config checkout, so
# edits apply without a rebuild) and HEX_BIN, and runs it on activation;
# `hex sync` runs it by hand.
#
#   settings.json        applied with `hex settings apply`; settings it doesn't
#                        name keep their values
#   vocabulary.json      shared vocabulary, committed
#   people.local.json    shared vocabulary that stays off GitHub (gitignored)
#
# The vocabulary files are the whole list: a term added in Hex's window and
# missing from both files is removed.

def --wrapped hex [...args: string] {
  ^$env.HEX_BIN ...$args
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

def main [] {
  let dir = $env.HEX_CONFIG

  let status = (do { hex status } | complete)
  if $status.exit_code == 3 {
    print "hex-sync: Hex isn't running; nothing synced"
    return
  }

  hex settings apply ($dir | path join settings.json)

  let wanted = (
    (read-terms ($dir | path join vocabulary.json))
    | append (read-terms ($dir | path join people.local.json))
    | each {|t| { term: $t.term, sounds_like: ($t.sounds_like? | default []) } }
  )
  let have = (hex vocabulary list --json | from json | get entries)

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
  let missing = ($wanted | where term not-in $kept)
  for t in $missing {
    if ($t.sounds_like | is-empty) {
      hex vocabulary add $t.term | ignore
    } else {
      hex vocabulary add $t.term --sounds-like ($t.sounds_like | str join ",") | ignore
    }
  }

  print $"hex-sync: ($wanted | length) vocabulary terms; ($missing | length) added, ($removed) removed"
}
