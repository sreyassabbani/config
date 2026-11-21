
; Wiki-link brackets use the near-background color in the notes theme.
(_
  "[" @ui.virtual.whitespace.wikilink
  .
  (shortcut_link "[" @ui.virtual.whitespace.wikilink (link_text) "]" @ui.virtual.whitespace.wikilink)
  .
  "]" @ui.virtual.whitespace.wikilink)
