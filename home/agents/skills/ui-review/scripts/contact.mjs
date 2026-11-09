#!/usr/bin/env node
// Contact sheet for the approval step: rows are viewers, columns are pages.
//   node contact.mjs RUN ENTITY VIEWPORT  → RUN/contact-ENTITY-VIEWPORT.png
// A cell whose view is pixel-identical to an earlier row's (after identity
// masking) says so instead of repeating the image. Run views.mjs first.
import { chromium } from "playwright-core";
import { readFileSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";

const [run, entity, vp] = process.argv.slice(2);
const rows = readFileSync(join(run, "index.tsv"), "utf8").trim().split("\n").slice(1).map((l) => l.split("\t"))
  .filter((r) => r[0] === entity && r[2] === vp);
const views = JSON.parse(readFileSync(join(run, "views.json"), "utf8"));
const viewers = [...new Set(rows.map((r) => r[1]))];
const pages = [...new Set(rows.map((r) => r[3]))];
const cell = (viewer, page) => {
  const r = rows.find((x) => x[1] === viewer && x[3] === page);
  if (!r) return `<td class="na">not captured</td>`;
  const [, , , , final, , png] = r;
  const rep = views[`${entity}/${page}/${vp}/${viewer}`];
  if (rep && rep !== viewer) return `<td class="dup">same as<br><b>${rep}</b></td>`;
  const note = final !== "same" ? `<div class="redir">→ ${final}</div>` : "";
  return `<td><img src="file://${resolve(png)}">${note}</td>`;
};
const W = vp === "phone" ? 150 : 300;
const html = `<!doctype html><meta charset="utf-8"><style>
body{margin:16px;background:#fff;font:13px/1.3 -apple-system,system-ui,sans-serif;color:#111}
table{border-collapse:collapse} td,th{border:1px solid #ddd;padding:6px;vertical-align:top;text-align:left}
th{background:#f5f5f5;font-weight:600} img{width:${W}px;display:block}
.dup,.na{width:${W}px;color:#777;text-align:center;vertical-align:middle} .redir{color:#b00;margin-top:4px}
</style><h3>${entity} · ${vp}</h3><table><tr><th></th>${pages.map((p) => `<th>${p}</th>`).join("")}</tr>
${viewers.map((v) => `<tr><th>${v}</th>${pages.map((p) => cell(v, p)).join("")}</tr>`).join("\n")}</table>`;
const htmlPath = resolve(join(run, `contact-${entity}-${vp}.html`));
writeFileSync(htmlPath, html);
const browser = await chromium.launch();
const page = await (await browser.newContext({ viewport: { width: 400, height: 400 } })).newPage();
await page.goto("file://" + htmlPath);
await page.waitForLoadState("load");
const out = htmlPath.replace(/\.html$/, ".png");
await page.screenshot({ path: out, fullPage: true });
await browser.close();
console.log(out);
