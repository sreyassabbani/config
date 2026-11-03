# Working environment

- This machine uses Nix. Machine configuration lives in `~/config`.
- For project commands, use `direnv exec . <command>` when the project has `.envrc`; otherwise use its Nix dev shell when available.
- Use Rex for persistent terminals and long-running commands; load the `rex` skill for its CLI guide.
- My interactive shell is Nushell: Ghostty and new Rex panes start `nu`. Write commands meant for me to paste in Nushell syntax. Text typed into a Rex shell pane with `rex send` is parsed by Nushell; for POSIX syntax, prefer `rex run -- program args` or `-- sh -c '...'`.
- Use `git` and `gh` directly for requested work. GitHub is authenticated as `sreyassabbani`; preserve the configured Git identity and commit signing.
