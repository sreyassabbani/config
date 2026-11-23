; Days: the daylink grammar finds weft's `@2026.11.22` in a paragraph's
; plain text. Named parts (links, code, emphasis) are left out of what it
; reads, and keep their own colors.
;
; Links get no grammar of their own, so `[target|alias]` is not split. Helix
; 25.07 drops one of two injections when one lies inside the other, so a
; link injection here would cost the color of every date in the same
; paragraph. tree-house fixed this on 2026-11-11 (b5206f0); once a Helix
; release carries it, a link injection can come back after this pattern.
((inline) @injection.content
  (#set! injection.language "daylink")
  (#set! injection.include-unnamed-children))
