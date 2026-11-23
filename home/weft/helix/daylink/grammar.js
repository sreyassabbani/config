// The plain text of a Markdown paragraph, for finding `@2026.11.22`: weft's
// link to that day's note. Like weft, a day counts only at the start of a
// word and not as the start of something longer.
module.exports = grammar({
  name: "daylink",
  extras: (_) => [/\s/],
  rules: {
    text: ($) => repeat(choice($.day, $._other)),
    day: (_) => /@\d{4}\.\d{2}\.\d{2}/,
    // Everything else, a word at a time. A word starting with `@` is only
    // the `@` (so a day can follow none); one starting elsewhere runs to the
    // next space, so `me@2026.11.22` stays one word. `@2026.11.223` and
    // `@2026.11.22.5` are longer than a day, so they win over it.
    _other: (_) =>
      choice(
        /[(\["]/,
        "@",
        /[^\s@(\["]\S*/,
        /@\d{4}\.\d{2}\.\d{2}(\w|[.\/-]\d)\S*/,
      ),
  },
});
