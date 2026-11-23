// The inside of a wiki link, `target|alias`, as Helix's Markdown parser
// hands it over (it parses `[[...]]` only as brackets around plain text).
// Injected from markdown.inline so the target and alias can be styled apart.
module.exports = grammar({
  name: "wikilink",
  extras: (_) => [],
  rules: {
    link: ($) => seq($.target, optional(seq("|", optional($.alias)))),
    target: (_) => /[^|]+/,
    alias: (_) => /[^|]+/,
  },
});
