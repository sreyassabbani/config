# T3 Code

`../t3code.nix` declares the existing model defaults, idle compaction behavior,
and selected UI preferences. Home Manager merges them into T3's writable
`~/.t3/userdata/settings.json` and `client-settings.json` on activation. This local
module provides the mutable merge behavior of the newer `programs.t3code` module
without changing this repo's pinned Home Manager or replacing the installed app.

Declared values win on each activation. Other fields, including provider
configuration, project overrides, and onboarding state, remain intact. Removing
a declaration leaves its last applied value in T3; reset it in T3 if needed.
Unchanged files are not rewritten. Invalid settings stop the merge before any
file is changed. Session databases and credential storage are not managed here.

The app may need restarting to reload externally changed client preferences.
