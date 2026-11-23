Link styling for Helix in weft's syntax, installed by `home/weft.nix`.

- `wikilink/` splits a link's text, `[...]` or `[[...]]`, at `|`. The notes
  theme draws the brackets, and the pipe and target of an aliased link,
  almost the same color as the background; aliases and unaliased targets use
  the normal link color.
- `daylink/` finds `@2026.11.22` in a paragraph's plain text and colors it
  as a link.

Each grammar's `src/` is generated from its `grammar.js` (`tree-sitter
generate`, with Node on PATH) and committed, so the build only compiles C.
The two `markdown-inline-*.scm` files are appended to Helix's own Markdown
queries; they decide which text each grammar reads.
