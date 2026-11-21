Wiki-link styling for Helix, installed by `home/weft.nix`.

Helix cannot hide text, so `[[target|alias]]` is drawn with the brackets,
the target and `|` as faint as whitespace markers, leaving the alias to read
as the link. `grammar.js` splits a link's text at `|`; `src/` is generated
from it (`tree-sitter generate`, with Node on PATH) and committed, so the
build only compiles C. The two `markdown-inline-*.scm` files are appended to
Helix's own Markdown queries.
