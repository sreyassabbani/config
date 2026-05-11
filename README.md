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
- `darwin/` is the Mac: packages, Homebrew apps, fonts, Dock defaults, the
  default browser, user shell, and system activation bits.
- `home/` is user environment: shell config, editor config, Git, GPG, SSH,
  Ghostty, project templates, and other local tooling.

### Experimental
- [`typst-figure`](home/typst.nix) creates an SVG figure file and opens it in Inkscape from inside
  Helix; still working out my specific setup for writing technical documents easily
