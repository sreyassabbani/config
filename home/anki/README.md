# Anki card templates

The front/back templates and CSS for my note types live here instead of in
Anki's template editor. [`notetypes.json`](notetypes.json) maps each note type
and card template to files in [`notetypes/`](notetypes); every note type gets
[`shared.css`](notetypes/shared.css), plus any extra CSS listed for it.

`anki-notetypes` (from [`../anki.nix`](../anki.nix)) writes them into the
desktop collection, using the `anki` library that matches the installed
Anki.app. It runs on every switch, but Anki locks the collection while it is
open, so then it skips and says so. To apply by hand:

```sh
anki-notetypes --dry-run --diff   # what would change
anki-notetypes --restart          # quit Anki, apply, reopen (it syncs on open)
```

Only template text and CSS change, so it reaches AnkiWeb, AnkiMobile and
[anki-blue](../anki-blue.nix) with a normal sync. Adding or removing card
templates or fields forces a full sync, so the script refuses; do that in Anki
desktop first, then mirror it here. Note types not listed are left alone.

## Layout rules

The old templates used `width: 50%` (a skinny column on phones) or a fixed
`600px` grid column (which overflowed and made AnkiWeb zoom the whole page
out). Now:

- text fills the screen up to a `32em` measure; nothing has a fixed width
- long words wrap, and images, tables and display math shrink or scroll
- the question stays in the same place on both sides; the answer appears below
  a short rule (`<hr id="answer">`, which desktop scrolls to)
- cloze blanks and revealed answers share one highlight, so your eye lands on
  the same spot when the card flips; `Back Extra` is smaller and muted
- light and night mode (`.nightMode`, AnkiDroid's `.night_mode`) via CSS
  variables at the top of `shared.css`
