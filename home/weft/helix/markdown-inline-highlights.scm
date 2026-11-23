; Link brackets use the near-background color in the notes theme: `[...]`
; where weft reads it as a link (not a footnote, `[x]`, or text with no
; letter or digit),
((shortcut_link "[" @ui.virtual.whitespace.wikilink (link_text) @markup.link.text "]" @ui.virtual.whitespace.wikilink)
  (#match? @markup.link.text "\\w")
  (#not-match? @markup.link.text "^(\\^|[xX]$)"))

; and `[[...]]`.
(_
  "[" @ui.virtual.whitespace.wikilink
  .
  (shortcut_link "[" @ui.virtual.whitespace.wikilink (link_text) @markup.link.text "]" @ui.virtual.whitespace.wikilink)
  .
  "]" @ui.virtual.whitespace.wikilink)
