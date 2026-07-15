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
    - opionated project setups (e.g. for Python: `uv`, `ruff`, `basedpyright`)
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
