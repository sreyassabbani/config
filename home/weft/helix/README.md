Link styling for Helix in weft's syntax, installed by `home/weft.nix`.

- `markdown-inline-highlights.scm` draws a link's brackets, `[...]` or
  `[[...]]`, almost the same color as the background (the notes theme's
  `ui.virtual.whitespace.wikilink`); the text inside uses the link color.
- `daylink/` is a small grammar that finds `@2026.11.22` in a paragraph's
  plain text and colors it as a link; `markdown-inline-injections.scm` hands
  it that text.

The two `markdown-inline-*.scm` files are appended to Helix's own Markdown
queries. `daylink/src/` is generated from its `grammar.js` (`tree-sitter
generate`, with Node on PATH) and committed, so the build only compiles C.
