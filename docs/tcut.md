# Terminal captures for posts

[`home/tcut.nix`](../home/tcut.nix) manages `~/.config/tcut/capture.json`:
the content repository, clipboard integration, Nushell, and capture geometry.
tcut reads the current Ghostty theme at capture time. It does not keep another
copy of the terminal palette in this configuration.

Capture a command locally, from any directory:

```nu
tcut capture --name <asset-name> -- <command> <args>
tcut capture --video --name <asset-name> -- <command> <args>
tcut capture --name typing --interactive -- tt -n 20
tcut capture --name screen --no-svg
```

The default is a selectable SVG still in the current directory; `--video`
chooses selectable HTML replay. No name uses a timestamp. For an interactive
game/editor, press **Ctrl+]** while it is visible to take the still before it
exits. `--no-svg` invokes the native macOS screenshot picker for actual PNG
pixels; it can capture an app that is already running.

`--post <post-slug>` is an optional adapter that exports to the canonical content
repository and copies an MDX embed. Paste that embed into the post yourself.
To attach a local selectable capture later, use
`tcut capture --from-cast ./typing.cast --post <post-slug> --name typing`.
`--stdin` accepts piped ANSI output and `--json` returns paths for composition.
Use a new terminal session after changing PATH. The managed
[`path.nu`](../home/nushell/path.nu) is a live link to this repository and puts
`~/.local/bin` first while preserving inherited paths.

#### Build and install the local fork

The tcut build requires Bun 1.4.1 or newer. The private build runtime at
`~/.local/share/tcut/bun` is pinned to [Bun 1.4.2](https://github.com/oven-sh/bun/releases/tag/bun-v1.4.2),
with its official archive SHA256 in `home/tcut.nix`. It leaves the Bun used by
other projects unchanged and avoids depending on temporary files.

Run these commands in Nushell after editing the local tcut worktree:

```nu
cd ~/workflow/tcut-blog
with-env {PATH: ([$"($env.HOME)/.local/share/tcut"] ++ $env.PATH)} {
    bun install --frozen-lockfile
    bun run --cwd packages/tcut install:local
}
tcut --version
```

The executable includes its Bun runtime. Normal captures need `tcut` and the
command being recorded; the private Bun is used when rebuilding the fork.
The original `~/workflow/tcut` checkout, including its native Ghostty capture
work, remains separate from `~/workflow/tcut-blog`.
