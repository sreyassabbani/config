# How I live

- 13" M4 MacBook Air, pretty much all configured via [Determinate Nix](https://determinate.systems/), [nix-darwin](https://github.com/nix-darwin/nix-darwin), Home Manager, and Homebrew
- Very opinionated.
- You might also like: [`sreyas.is/using`](https://sreyas.is/using)

Of the many things this repo configures, the following are important notes:
- [Helix](home/helix.nix) (w/ e.g. language servers, formatters, keybinds)
  - custom [snippets](home/helix/snippets)
- [Nushell](home/nushell.nix) in [Ghostty](home/ghostty.nix)
  - [`zoxide` bound](home/nushell/zoxide.nu) to `cd`
  - easy project management with [`direnv`](home/direnv.nix)
  - easy [project startup](home/nushell/ds.nu) with [auto-gen templates](home/nushell/templates)
    - opinionated project setups (e.g. for Python: `uv`, `ruff`, `basedpyright`)
- [Zen](darwin/homebrew.nix:60) as the browser,
- Catppuccin Frappe everywhere possible
- Mac setup
  - `caps lock` remapped to `esc`
  - dock is small, hidden, and is very minimal

Overall: generally,
- [`darwin/`](darwin) is the Mac: [packages](darwin/packages.nix),
  [Homebrew apps](darwin/homebrew.nix), [fonts](darwin/fonts.nix),
  [Dock defaults](darwin/defaults.nix), the [default browser](darwin/activation.nix),
  [user shell](darwin/users.nix), and [system activation bits](darwin/activation.nix).
- [`home/`](home) is user environment: [shell config](home/nushell.nix),
  [editor config](home/helix.nix), [Git](home/git.nix), [GPG](home/gpg.nix),
  [SSH](home/ssh.nix), [Ghostty](home/ghostty.nix),
  [project templates](home/nushell/templates), and [other local tooling](home/core.nix).

### Experimental
- [`typst-figure`](home/typst.nix) creates an SVG figure file and opens it in Inkscape from inside
  Helix; still working out my specific setup for writing technical documents easily

### Terminal captures for posts

[`home/tcut.nix`](home/tcut.nix) manages `~/.config/tcut/capture.json`:
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
[`path.nu`](home/nushell/path.nu) is a live link to this repository and puts
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

### Typing test colors

[`tt`](https://github.com/lemnos/tt) is built from the local
`~/workflow/tt` checkout through the `tt-src` flake input and
[`pkgs/tt.nix`](pkgs/tt.nix). Its updated tcell renderer recognizes Ghostty and
preserves theme RGB colors, including `bgcol`. The Catppuccin Frappe theme is
managed in [`home/tt.nix`](home/tt.nix).

After editing that checkout, refresh the source snapshot and build it:

```nu
cd ~/config
nix flake update tt-src
nix build .#tt
./result/bin/tt -theme catppuccin-frappe
```

The next normal configuration activation installs this same package as `tt`
and updates `~/.local/bin/tt`. Existing screenshots retain their recorded colors;
capture them again after changing the game or its theme.
