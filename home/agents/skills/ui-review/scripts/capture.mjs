#!/usr/bin/env node
// Capture every viewer × viewport × page in a manifest.
//   node capture.mjs MANIFEST.json
// Writes, under the manifest's `out` (relative to the manifest):
//   manifest.json                     a copy, read by views.mjs
//   index.tsv                         one row per capture
//   <entity>/<viewer>--<viewport>/<page>.png and .txt
// The .txt is the inventory: final path, "still loading", console errors, then
// visible headings and controls with state and box. Finders never get it.
// Each page gets a fresh tab with a neutral baseline: pointer at (0, 0), focus
// blurred, reduced motion, animations disabled, the Next dev overlay hidden.
// Sessions are cached for 6 hours in ~/.cache/ui-review/auth, outside any repo.
import { chromium } from "playwright-core";
import { readFileSync, existsSync, mkdirSync, statSync, writeFileSync, appendFileSync, copyFileSync } from "node:fs";
import { join, dirname, resolve } from "node:path";
import { homedir } from "node:os";

const PRESETS = {
  desktop: { viewport: { width: 1440, height: 900 } },
  laptop: { viewport: { width: 1280, height: 800 } },
  tablet: { viewport: { width: 768, height: 1024 }, hasTouch: true },
  phone: { viewport: { width: 390, height: 844 }, isMobile: true, hasTouch: true },
  small: { viewport: { width: 320, height: 640 }, isMobile: true, hasTouch: true },
};
const viewportOpts = (vp) => {
  const m = vp.match(/^(\d+)x(\d+)$/);
  const o = m ? { viewport: { width: +m[1], height: +m[2] } } : PRESETS[vp];
  if (!o) throw new Error(`unknown viewport ${vp}`);
  return o;
};

const mpath = resolve(process.argv[2] ?? "");
if (!process.argv[2] || !existsSync(mpath)) { console.error("usage: capture.mjs MANIFEST.json"); process.exit(2); }
const m = JSON.parse(readFileSync(mpath, "utf8"));
const app = m.app;
const out = resolve(dirname(mpath), m.out ?? ".");
mkdirSync(out, { recursive: true });
copyFileSync(mpath, join(out, "manifest.json"));

// The password is read from the app's own file and never printed.
const password = () => {
  const src = readFileSync(resolve(app.root ?? ".", app.passwordFrom.file), "utf8");
  const hit = src.match(new RegExp(app.passwordFrom.pattern));
  if (!hit) throw new Error(`no password match in ${app.passwordFrom.file}`);
  return hit[1];
};

const authDir = join(process.env.XDG_CACHE_HOME ?? join(homedir(), ".cache"), "ui-review", "auth",
  new URL(app.base).host.replace(/[^a-z0-9.-]/gi, "_"));
async function authState(browser, user) {
  mkdirSync(authDir, { recursive: true, mode: 0o700 });
  const path = join(authDir, `${user}.json`);
  if (existsSync(path) && Date.now() - statSync(path).mtimeMs < 6 * 3600e3) return path;
  const ctx = await browser.newContext(PRESETS.desktop);
  const page = await ctx.newPage();
  const login = app.login;
  try {
    await page.goto(app.base + login.path, { waitUntil: "domcontentloaded", timeout: 90000 });
    // Submitting before React hydrates does a native GET that puts the password in the URL.
    await page.waitForFunction(() => {
      const form = document.querySelector("form");
      return !!form && Object.keys(form).some((k) => k.startsWith("__reactProps"));
    }, null, { timeout: 90000 });
    await page.locator(login.user).fill(user);
    await page.locator(login.password).fill(password());
    await page.locator(login.submit ?? "form button[type=submit]").first().click();
    await page.waitForURL((u) => !u.pathname.startsWith(login.path), { timeout: 60000 });
    await ctx.storageState({ path });
  } catch (e) {
    // Playwright errors quote the URL; keep any credential out of the log.
    throw new Error(`login as ${user} failed: ${String(e.message).split("\n")[0].replace(/\?.*/, "")}`);
  } finally { await ctx.close(); }
  return path;
}

async function settle(page, ms) {
  await page.waitForLoadState("domcontentloaded").catch(() => {});
  // Apps with live sockets never reach networkidle; wait for loading markers instead.
  const loaded = await page.waitForFunction(() => {
    const busy = document.querySelector('[aria-busy="true"], [data-slot="skeleton"], .animate-pulse');
    return !busy || busy.getBoundingClientRect().height === 0;
  }, null, { timeout: 10000 }).then(() => true, () => false);
  await page.waitForTimeout(ms);
  return loaded;
}

// Visible headings and controls with their state, in document order.
const inventory = (page) => page.evaluate(() => {
  const vis = (el) => {
    const r = el.getBoundingClientRect(); const cs = getComputedStyle(el);
    return r.width > 0 && r.height > 0 && cs.visibility !== "hidden" && cs.display !== "none" &&
      r.bottom > 0 && r.top < innerHeight && r.right > 0 && r.left < innerWidth;
  };
  const sel = "h1,h2,h3,h4,[role=heading],button,a[href],input,select,textarea,[role=button],[role=tab],[role=switch],[role=checkbox],[role=menuitem],[role=combobox]";
  const label = (el) => (el.getAttribute("aria-label") || el.innerText || el.getAttribute("placeholder") || el.value || "")
    .trim().replace(/\s+/g, " ").slice(0, 70);
  return [...document.querySelectorAll(sel)].filter(vis).map((el) => {
    const r = el.getBoundingClientRect();
    const kind = el.getAttribute("role") || el.tagName.toLowerCase();
    const st = [
      el.getAttribute("aria-checked") === "true" || el.checked ? "on" : "",
      el.getAttribute("aria-selected") === "true" || el.getAttribute("aria-current") ? "current" : "",
      el.disabled || el.getAttribute("aria-disabled") === "true" ? "disabled" : "",
    ].filter(Boolean).join(",");
    return `${kind}\t${label(el)}\t${st}\t${Math.round(r.x)},${Math.round(r.y)},${Math.round(r.width)}x${Math.round(r.height)}`;
  }).join("\n");
});

async function shoot(ctx, url, png, waitMs) {
  const page = await ctx.newPage();
  const errors = [];
  page.on("console", (msg) => { if (msg.type() === "error") errors.push(msg.text()); });
  page.on("pageerror", (e) => errors.push(e.message));
  await page.goto(url, { waitUntil: "domcontentloaded", timeout: 90000 });
  const loaded = await settle(page, waitMs);
  await page.mouse.move(0, 0);
  await page.evaluate(() => document.activeElement instanceof HTMLElement && document.activeElement.blur());
  await page.addStyleTag({ content: "nextjs-portal{display:none!important}" }).catch(() => {});
  await page.screenshot({ path: png, animations: "disabled", caret: "hide" });
  const finalPath = new URL(page.url()).pathname;
  const head = [`# final ${finalPath}`, loaded ? null : "# still loading after 10s",
    ...errors.map((e) => `# error ${e.replace(/\s+/g, " ").slice(0, 300)}`)].filter(Boolean).join("\n");
  writeFileSync(png.replace(/\.png$/, ".txt"), `${head}\n${await inventory(page)}\n`);
  await page.close();
  return { finalPath, errors: errors.length };
}

const theme = m.theme ?? "dark";
const browser = await chromium.launch({ headless: true });
const index = join(out, "index.tsv");
writeFileSync(index, "entity\tviewer\tviewport\tpage\tfinal\terrors\tpng\n");
try {
  for (const v of m.viewers) {
    const ids = m.entities[v.entity];
    const storageState = await authState(browser, v.id);
    for (const vp of v.viewports) {
      const ctx = await browser.newContext({
        ...viewportOpts(m.viewports?.[vp] ?? vp), storageState, reducedMotion: "reduce",
        colorScheme: m.colorScheme ?? "dark",
      });
      if (app.themeKey) await ctx.addInitScript(([k, t]) => { try { localStorage.setItem(k, t); } catch {} }, [app.themeKey, theme]);
      const dir = join(out, v.entity, `${v.label}--${vp}`);
      mkdirSync(dir, { recursive: true });
      for (const [page, tmpl] of Object.entries(m.pages)) {
        const route = tmpl.replace(/\{(\w+)\}/g, (_, k) => ids[k] ?? `{${k}}`);
        const png = join(dir, `${page}.png`);
        try {
          const r = await shoot(ctx, app.base + route, png, Number(m.waitMs ?? 1200));
          let moved = "same";
          if (r.finalPath !== route) {
            moved = r.finalPath;
            for (const [k, id] of Object.entries(ids)) if (k !== "name") moved = moved.replaceAll(id, `{${k}}`);
          }
          appendFileSync(index, `${v.entity}\t${v.label}\t${vp}\t${page}\t${moved}\t${r.errors}\t${png}\n`);
          console.log(`${v.entity} ${v.label} ${vp} ${page}: ${moved}${r.errors ? ` (${r.errors} console errors)` : ""}`);
        } catch (e) {
          console.log(`${v.entity} ${v.label} ${vp} ${page}: FAILED ${String(e.message).split("\n")[0]}`);
        }
      }
      await ctx.close();
    }
  }
} finally { await browser.close(); }
