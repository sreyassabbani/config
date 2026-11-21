; The inside of a wiki link. The two patterns never match the same link.

; `[[target]]`: the target is what reads.
(link (target) @markup.link.text .)

; `[[target|alias]]`: the target is faint and the pipe uses the bracket color.
(link
  (target) @ui.virtual.whitespace
  "|" @ui.virtual.whitespace.wikilink
  (alias)? @markup.link.text)
