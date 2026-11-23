; Link brackets use the near-background color in the notes theme: `[...]`,
; where it is a link (see the injections),
((shortcut_link "[" @ui.virtual.whitespace.wikilink (link_text) @_text "]" @ui.virtual.whitespace.wikilink)
  (#match? @_text "\\w")
  (#not-match? @_text "^(\\^|[xX]$)"))

; and `[[...]]`.
(_
  "[" @ui.virtual.whitespace.wikilink
  .
  (shortcut_link "[" @ui.virtual.whitespace.wikilink (link_text) "]" @ui.virtual.whitespace.wikilink)
  .
  "]" @ui.virtual.whitespace.wikilink)
