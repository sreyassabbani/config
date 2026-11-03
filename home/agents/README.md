# Agents

`instructions.md` is the shared source for Codex's `~/.codex/AGENTS.md`, Claude
Code's `~/.claude/CLAUDE.md`, OpenCode's `~/.config/opencode/AGENTS.md`, and Gemini
CLI's `~/.gemini/GEMINI.md`. Home Manager deploys it; start a fresh agent session
after activation. Keep this file limited to working habits that agents need on
every project.

`skills/` holds personally maintained skills. Home Manager links each one into
`~/.claude/skills` and `~/.codex/skills` (OpenCode reads the Claude copy). The links
point at this checkout, so edits apply immediately; adding or removing a skill
needs a rebuild. Third-party and plugin skills keep their existing owners.

Rex's CLI is linked from its installed Mac app by `home/rex.nix`. Rex owns its
generated skill stub. Zsh appends `~/.local/bin`, `~/.t3/bin`, and the Homebrew
tool paths even in non-interactive shells, preserving any existing dev shell's
precedence.

T3's declared preferences live in `../t3code.nix`. Its app and runtime state
remain managed by T3; see `../t3code/README.md` for activation behavior.

## Still open

- Model favorites, shortcuts, and additional UI preferences are optional; add
  deliberate choices rather than importing every runtime setting.
- Add host-specific configuration when a second machine exists. The absolute
  `tt-src` flake input needs addressing before bootstrapping one.
- Other agent adapters, including Cursor, need their own loading checks before
  being counted as covered.
