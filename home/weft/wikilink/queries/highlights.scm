; The inside of a wiki link. The two patterns never match the same link.

; `[[target]]`: the target is what reads.
(link (target) @markup.link.text .)

; `[[target|alias]]`: only the alias reads; the target and `|` are drawn as
; faintly as whitespace markers, so the link looks like its alias (hover or
; `gd` still show where it goes).
(link
  (target) @ui.virtual.whitespace
  "|" @ui.virtual.whitespace
  (alias)? @markup.link.text)
