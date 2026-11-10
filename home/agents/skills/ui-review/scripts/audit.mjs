#!/usr/bin/env node
// Find the finder runs whose task named INPUT_DIR, check that each stayed
// sealed, print its stats, and optionally save its output and reasoning.
//   node audit.mjs INPUT_DIR [--since ISO] [--model TEXT] [--save DIR --as NAME]
// Searches Claude transcripts (~/.claude/projects) and Codex rollouts
// (~/.codex/sessions) changed since --since (default: 24 hours ago).
// --model keeps runs whose model id contains TEXT.
// A run passes only when every operation views an image inside INPUT_DIR.
// --once also rejects repeated views (for briefs that require one per image).
// --save writes DIR/NAME-<n>.md (the final message, verbatim) and
// DIR/NAME-<n>-reasoning.md, numbering runs by start time. Both tools log a
// summary of the model's reasoning, not the raw reasoning.
import { readFileSync, readdirSync, statSync, existsSync, mkdirSync, writeFileSync } from "node:fs";
import { join, resolve, basename } from "node:path";
import { homedir } from "node:os";
import { parseArgs } from "node:util";
import { auditCalls } from "./audit-tools.mjs";

const { values: opt, positionals } = parseArgs({
  allowPositionals: true,
  options: { since: { type: "string" }, model: { type: "string" }, save: { type: "string" }, as: { type: "string" }, once: { type: "boolean" } },
});
if (!positionals[0] || (opt.save && !opt.as)) {
  console.error("usage: audit.mjs INPUT_DIR [--since ISO] [--model TEXT] [--save DIR --as NAME]");
  process.exit(2);
}
const input = resolve(positionals[0]).replace(/\/$/, "") + "/";
const since = opt.since ? Date.parse(opt.since) : Date.now() - 24 * 3600e3;

const files = (root) => {
  if (!existsSync(root)) return [];
  return readdirSync(root, { recursive: true }).filter((f) => String(f).endsWith(".jsonl"))
    .map((f) => join(root, String(f))).filter((f) => statSync(f).mtimeMs >= since);
};
const textOf = (content) => typeof content === "string" ? content
  : (content ?? []).map((c) => c.text ?? "").join("\n");

function parseClaude(lines) {
  const r = { tool: "claude", tasks: [], calls: [], reasoning: [], usage: {}, requests: new Set(), texts: new Map() };
  for (const l of lines) {
    if (l.timestamp) { r.start ??= l.timestamp; r.end = l.timestamp; }
    if (l.type === "user" && !l.message?.content?.some?.((c) => c.type === "tool_result")) r.tasks.push(textOf(l.message?.content));
    if (l.type !== "assistant" || !l.message) continue;
    const msg = l.message;
    r.model ??= msg.model;
    r.requests.add(msg.id);
    if (msg.usage) r.usage[msg.id] = msg.usage;
    for (const c of msg.content ?? []) {
      if (c.type === "tool_use") r.calls.push({ name: c.name, text: JSON.stringify(c.input) });
      if (c.type === "thinking" && c.thinking) r.reasoning.push(c.thinking);
      if (c.type === "text" && c.text) r.texts.set(msg.id, [...(r.texts.get(msg.id) ?? []), c.text]);
    }
  }
  const u = Object.values(r.usage);
  const sum = (k) => u.reduce((n, x) => n + (x[k] ?? 0), 0);
  r.tokens = { input: sum("input_tokens"), cacheRead: sum("cache_read_input_tokens"),
    cacheWrite: sum("cache_creation_input_tokens"), output: sum("output_tokens") };
  r.final = ([...r.texts.values()].at(-1) ?? []).join("\n\n");
  r.requests = r.requests.size;
  return r;
}

function parseCodex(lines) {
  const r = { tool: "codex", tasks: [], calls: [], reasoning: [], requests: 0, final: "" };
  let total = {};
  for (const l of lines) {
    if (l.timestamp) { r.start ??= l.timestamp; r.end = l.timestamp; }
    const p = l.payload ?? {};
    if (l.type === "turn_context") r.model ??= p.model;
    if (l.type === "event_msg" && p.type === "token_count" && p.info) { r.requests++; total = p.info.total_token_usage ?? total; }
    if (l.type !== "response_item") continue;
    if (p.type === "message" && p.role === "user") r.tasks.push(textOf(p.content));
    if (p.type === "message" && p.role === "assistant") r.final = textOf(p.content);
    if (p.type === "reasoning") r.reasoning.push(...(p.summary ?? []).map((s) => s.text));
    if (p.type === "function_call") r.calls.push({ name: p.name, text: p.arguments ?? "" });
    if (p.type === "custom_tool_call") r.calls.push({ name: p.name, text: p.input ?? "" });
    if (p.type === "local_shell_call") r.calls.push({ name: "shell", text: JSON.stringify(p.action ?? {}) });
  }
  r.tokens = { input: total.input_tokens ?? 0, cacheRead: total.cached_input_tokens ?? 0,
    cacheWrite: total.cache_write_input_tokens ?? 0, output: total.output_tokens ?? 0,
    reasoning: total.reasoning_output_tokens ?? 0 };
  return r;
}

const runs = [];
const roots = [[join(homedir(), ".claude", "projects"), parseClaude], [join(homedir(), ".codex", "sessions"), parseCodex]];
for (const [root, parse] of roots) {
  for (const f of files(root)) {
    const raw = readFileSync(f, "utf8");
    if (!raw.includes(input)) continue;
    const lines = raw.split("\n").filter(Boolean).flatMap((s) => { try { return [JSON.parse(s)]; } catch { return []; } });
    const r = parse(lines);
    if (!r.tasks.some((t) => t.includes(input))) continue; // named it somewhere else, e.g. the orchestrator
    if (opt.model && !String(r.model).includes(opt.model)) continue;
    r.file = f;
    const audit = auditCalls(r.calls, input, { once: opt.once });
    r.viewed = audit.viewed;
    r.leaks = audit.violations;
    const expected = readdirSync(input).filter(f => /\.(png|jpe?g|webp)$/i.test(f)).map(f => resolve(input, f));
    for (const path of expected.filter(p => !r.viewed.includes(p)))
      r.leaks.push({ name: "coverage", text: path, reason: "input image was not viewed" });
    for (const path of r.viewed.filter(p => !expected.includes(p)))
      r.leaks.push({ name: "coverage", text: path, reason: "image is not in the input inventory" });
    runs.push(r);
  }
}
runs.sort((a, b) => String(a.start).localeCompare(String(b.start)));

const k = (n) => n >= 1000 ? `${(n / 1000).toFixed(1)}k` : String(n);
runs.forEach((r, i) => {
  const wall = r.start && r.end ? Math.round((Date.parse(r.end) - Date.parse(r.start)) / 1000) : "?";
  const t = r.tokens;
  const name = opt.as ? `${opt.as}-${i + 1}` : `run ${i + 1}`;
  console.log(`${name}: ${r.model} (${r.tool}) ${basename(r.file)}`);
  console.log(`  started ${r.start}, ${wall} s, ${r.requests} model requests, ${r.calls.length} tool calls`);
  console.log(`  tokens: input ${k(t.input)}, cache read ${k(t.cacheRead)}, cache write ${k(t.cacheWrite)}, output ${k(t.output)}` +
    (t.reasoning ? ` (reasoning ${k(t.reasoning)})` : "") + `; reasoning log ${k(r.reasoning.join("").length)} chars`);
  console.log(r.leaks.length ? `  EXCLUDED (tool/input policy):\n${r.leaks.map((c) => `    ${c.name}: ${c.reason}; ${c.text.slice(0, 200)}`).join("\n")}` : `  passed: ${r.viewed.length} image views; no other operations`);
  if (!r.final) console.log("  no final message");
  if (opt.save) {
    mkdirSync(opt.save, { recursive: true });
    writeFileSync(join(opt.save, `${name}.md`), r.final.trimEnd() + "\n");
    writeFileSync(join(opt.save, `${name}-reasoning.md`),
      `# ${name}: logged reasoning (${r.model})\n\nTranscript: ${r.file}\n\n` + r.reasoning.join("\n\n---\n\n").trimEnd() + "\n");
  }
});
if (!runs.length) console.log("no runs found whose task names " + input);
if (opt.save) writeFileSync(join(opt.save, `${opt.as}-audit.json`), JSON.stringify(runs.map(r => ({
  model: r.model, file: r.file, start: r.start, end: r.end, tokens: r.tokens,
  requests: r.requests, calls: r.calls.length, viewed: r.viewed, violations: r.leaks,
  eligible: r.leaks.length === 0 && !!r.final,
})), null, 2) + "\n");
