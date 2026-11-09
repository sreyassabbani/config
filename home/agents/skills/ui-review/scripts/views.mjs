#!/usr/bin/env node
// Group a run's captures into distinct views by exact pixels, per entity × page × viewport.
//   node views.mjs RUN   → RUN/views.json ("entity/page/viewport/viewer" → representative viewer)
// Masked before comparing, from RUN/manifest.json:
// - `identity`: regexes matched against inventory labels, for fields that differ
//   by person (account name, presence counts). Every image in a group gets the
//   union of the group's boxes, padded by 4px, since a name's length changes
//   its button's width;
// - `shell`: per viewport, the width of a left app sidebar that is reviewed once
//   per viewer rather than per page.
import { chromium } from "playwright-core";
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const run = process.argv[2];
if (!run) { console.error("usage: views.mjs RUN"); process.exit(2); }
const m = JSON.parse(readFileSync(join(run, "manifest.json"), "utf8"));
const identity = (m.identity ?? []).map((s) => new RegExp(s));
const rows = readFileSync(join(run, "index.tsv"), "utf8").trim().split("\n").slice(1).map((l) => l.split("\t"));
const masks = (png) => readFileSync(png.replace(/\.png$/, ".txt"), "utf8").split("\n")
  .map((l) => l.split("\t")).filter((c) => c.length >= 4 && identity.some((re) => re.test(c[1])))
  .map((c) => { const [x, y, wh] = c[3].split(","); const [w, h] = wh.split("x"); return [+x, +y, +w, +h]; });

const groups = {};
for (const r of rows) (groups[`${r[0]}\t${r[3]}\t${r[2]}`] ??= []).push({ viewer: r[1], png: r[6] });
const browser = await chromium.launch();
const page = await browser.newPage();
const views = {};
for (const [key, list] of Object.entries(groups)) {
  const [entity, pg, vp] = key.split("\t");
  const boxes = list.flatMap((x) => masks(x.png)).map(([x, y, w, h]) => [x - 4, y - 4, w + 8, h + 8]);
  const shell = m.shell?.[vp] ?? 0;
  const items = list.map((x) => "data:image/png;base64," + readFileSync(x.png).toString("base64"));
  const reps = await page.evaluate(async ({ items, boxes, shell }) => {
    const load = (s) => new Promise((res) => { const i = new Image(); i.onload = () => res(i); i.src = s; });
    const px = [];
    for (const src of items) {
      const i = await load(src);
      const c = document.createElement("canvas"); c.width = i.width; c.height = i.height;
      const g = c.getContext("2d"); g.drawImage(i, 0, 0); g.fillStyle = "#f0f";
      if (shell) g.fillRect(0, 0, shell, i.height);
      for (const [x, y, w, h] of boxes) g.fillRect(x, y, w, h);
      px.push(g.getImageData(0, 0, c.width, c.height).data);
    }
    const rep = [];
    px.forEach((d, i) => {
      let same = -1;
      for (let j = 0; j < i && same < 0; j++) {
        if (rep[j] !== j || px[j].length !== d.length) continue;
        const e = px[j]; let k = 0;
        for (; k < d.length; k++) if (d[k] !== e[k]) break;
        if (k === d.length) same = j;
      }
      rep.push(same < 0 ? i : same);
    });
    return rep;
  }, { items, boxes, shell });
  reps.forEach((r, i) => { views[`${entity}/${pg}/${vp}/${list[i].viewer}`] = list[r].viewer; });
  const merged = reps.map((r, i) => (r !== i ? `${list[i].viewer}=${list[r].viewer}` : null)).filter(Boolean);
  console.log(`${entity} ${pg} ${vp}: ${new Set(reps).size} of ${list.length}${merged.length ? "  (" + merged.join(", ") + ")" : ""}`);
}
await browser.close();
writeFileSync(join(run, "views.json"), JSON.stringify(views, null, 1) + "\n");
