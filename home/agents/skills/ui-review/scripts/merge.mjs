#!/usr/bin/env node
// Render merged findings from the orchestrator's clusters, without losing words.
//   node merge.mjs FINDINGS_DIR
// Reads FINDINGS_DIR/clusters.json:
//   { "title": "...", "runs": ["haiku-1", ...],
//     "clusters": [{ "title": "...", "captures": "1 2", "ids": ["haiku-1:F3", ...] }] }
// and each run's verbatim output, FINDINGS_DIR/<run>.md, split at "### F<n>:".
// Writes merged.md (a table per number of runs, with an empty Label column) and
// merged-verbatim.md (every cluster followed by each run's full block).
// Fails, writing nothing, if an id is unknown or a block is in no cluster.
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const dir = process.argv[2];
if (!dir) { console.error("usage: merge.mjs FINDINGS_DIR"); process.exit(2); }
const spec = JSON.parse(readFileSync(join(dir, "clusters.json"), "utf8"));

const blocks = new Map(); // "run:F3" -> { title, body }
for (const run of spec.runs) {
  const text = readFileSync(join(dir, `${run}.md`), "utf8");
  for (const part of text.split(/^(?=### F\d+:)/m).filter((p) => p.startsWith("### F"))) {
    const [head, ...rest] = part.replace(/\n+Examined:.*$/s, "").trimEnd().split("\n");
    const [, id, title] = head.match(/^### (F\d+):\s*(.*)$/);
    blocks.set(`${run}:${id}`, { title, body: rest.join("\n").replace(/\n+---\s*$/, "").trimEnd() });
  }
}

const unknown = spec.clusters.flatMap((c) => c.ids.filter((id) => !blocks.has(id)));
const used = new Set(spec.clusters.flatMap((c) => c.ids));
const loose = [...blocks.keys()].filter((id) => !used.has(id));
if (unknown.length || loose.length) {
  if (unknown.length) console.error(`unknown ids: ${unknown.join(", ")}`);
  if (loose.length) console.error(`blocks in no cluster: ${loose.join(", ")}`);
  process.exit(1);
}

const runsOf = (c) => spec.runs.filter((r) => c.ids.some((id) => id.startsWith(r + ":")));
const cite = (c) => runsOf(c).map((r) => `${r} ${c.ids.filter((id) => id.startsWith(r + ":")).map((id) => id.split(":")[1]).join(" ")}`).join(", ");
const n = spec.runs.length;
const sections = [];
for (let k = n; k >= 1; k--) {
  const list = spec.clusters.filter((c) => runsOf(c).length === k);
  if (list.length) sections.push([k === n ? `Found by all ${n}` : k === 1 ? "Found by one" : `Found by ${k}`, list]);
}
let num = 0;
const numbered = sections.map(([h, list]) => [h, list.map((c) => ({ ...c, num: ++num }))]);
const cell = (s) => String(s).replace(/\|/g, "\\|");

const merged = [`# ${spec.title}: merged`, "",
  `Runs: ${spec.runs.map((r) => `${r} (${[...blocks.keys()].filter((id) => id.startsWith(r + ":")).length})`).join(", ")}. ` +
  `${spec.clusters.length} clusters. Labels: real / not real / partly. Full text: merged-verbatim.md.`,
  ...numbered.flatMap(([h, list]) => ["", `## ${h}`, "", "| # | Finding | Captures | Runs | Label |", "|---|---|---|---|---|",
    ...list.map((c) => `| ${c.num} | ${cell(c.title)} | ${cell(c.captures ?? "")} | ${cell(cite(c))} | |`)]),
].join("\n") + "\n";

const verbatim = [`# ${spec.title}: merged, verbatim`, "",
  "Every cluster, then each run's block exactly as the run wrote it.",
  ...numbered.flatMap(([, list]) => list.flatMap((c) => ["", `## ${c.num}. ${c.title}`,
    ...c.ids.flatMap((id) => { const b = blocks.get(id); return ["", `### ${id.replace(":", " · ")}: ${b.title}`, b.body]; })])),
].join("\n") + "\n";

writeFileSync(join(dir, "merged.md"), merged);
writeFileSync(join(dir, "merged-verbatim.md"), verbatim);
console.log(`${spec.clusters.length} clusters from ${blocks.size} blocks → merged.md, merged-verbatim.md`);
