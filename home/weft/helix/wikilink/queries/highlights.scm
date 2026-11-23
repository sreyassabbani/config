; The inside of a link, `[...]` or `[[...]]`. The two patterns never match
; the same link.

; `[target]`: the target is what reads.
(link (target) @markup.link.text .)

; `[target|alias]`: the target and pipe use the bracket color.
(link
  (target) @ui.virtual.whitespace.wikilink
  "|" @ui.virtual.whitespace.wikilink
  (alias)? @markup.link.text)
