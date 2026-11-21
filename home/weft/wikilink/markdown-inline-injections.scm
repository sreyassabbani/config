
; Wiki links: the text inside `[[...]]` goes to the wikilink grammar, which
; splits it into target and alias. Helix's parser reads `[[a|b]]` as a
; shortcut link `[a|b]` inside brackets, which is what this matches.
(_ "[" . (shortcut_link (link_text) @injection.content) . "]"
  (#set! injection.language "wikilink")
  (#set! injection.include-children))
