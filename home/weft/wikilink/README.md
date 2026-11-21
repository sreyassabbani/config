Wiki-link styling for Helix, installed by `home/weft.nix`.

The notes theme draws the brackets and `|` almost the same color as the
background. An aliased link's target uses the whitespace-marker color,
while its alias uses the normal link color. `grammar.js` splits a link's text
at `|`. The `src/` directory is generated
from it (`tree-sitter generate`, with Node on PATH) and committed, so the
build only compiles C. The two `markdown-inline-*.scm` files are appended to
Helix's own Markdown queries.
