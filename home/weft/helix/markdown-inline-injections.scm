; Days: the daylink grammar finds weft's `@2026.11.22` in a paragraph's
; plain text. Named parts (links, code, emphasis) are left out of what it
; reads, and keep their own colors. This pattern must come before the link
; one: the other way round, Helix drops the link injection.
((inline) @injection.content
  (#set! injection.language "daylink")
  (#set! injection.include-unnamed-children))

; Links: the text inside `[...]` and `[[...]]` goes to the wikilink grammar,
; which splits it into target and alias. Helix's parser reads `[[a|b]]` as a
; shortcut link `[a|b]` inside brackets, so one pattern covers both. Left
; alone, as weft leaves them: footnotes (`[^1]`), `[x]`, and text with no
; letter or digit in it.
((shortcut_link (link_text) @injection.content)
  (#match? @injection.content "\\w")
  (#not-match? @injection.content "^(\\^|[xX]$)")
  (#set! injection.language "wikilink")
  (#set! injection.include-children))
