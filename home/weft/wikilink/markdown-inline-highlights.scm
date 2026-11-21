
; Wiki links: `[[` and `]]` as faint as whitespace markers.
(_
  "[" @ui.virtual.whitespace
  .
  (shortcut_link "[" @ui.virtual.whitespace (link_text) "]" @ui.virtual.whitespace)
  .
  "]" @ui.virtual.whitespace)
