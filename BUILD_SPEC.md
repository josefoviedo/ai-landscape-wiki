# BUILD_SPEC.md — AI Landscape dashboard

You are building **AI Landscape**: a local, single-user, interactive map of the AI
tooling ecosystem. Categories float as glowing suns in a galaxy; clicking one zooms
into its orbit of players; clicking a player shows a plain-language summary (PLS)
and a button that generates a deep-research prompt for the user's local agent.
When that agent later drops a report file into this folder, the app notices by
itself and lights up.

Read this whole file before writing code. `AGENT.md` (the update contract) and
`data/landscape.json` (researched seed: 17 categories, 189 players) already exist —
**do not regenerate, rename, or restructure either**. Your deliverable is
`index.html` plus verification.

## 1. Hard constraints

- **One file.** All HTML, CSS, and JS inline in `index.html`. No build step, no
  frameworks, no dependencies, no CDN/external requests, no web fonts. Vanilla ES2020+,
  SVG and/or Canvas.
- **Served locally.** The app runs from `./run.command` / `./run.sh` (already in this
  folder — `chmod +x` them), i.e. `python3 -m http.server 8787`. All fetches are
  same-origin relative paths.
- **Data-driven.** Render everything from `data/landscape.json`. Zero hardcoded
  category/player names in JS. New categories/players appearing in the JSON must
  render without code changes (colors cycle: `PALETTE[index % 17]`).
- **No browser storage** (localStorage/sessionStorage) — in-memory state + URL hash only.
- **Graceful `file://` failure:** if `fetch` of the JSON fails, show a centered
  friendly card: "Open me via ./run.command — I need a local server to load data."
- Target Chrome + Safari (current). Performance budget: 60fps galaxy/orbit animation
  on a MacBook; ≤ 200 ms initial render after JSON load.

## 2. Files (final state)

```
ai-landscape-wiki/
  index.html            ← you build this (the entire app)
  data/landscape.json   ← provided; app reads + polls it
  reports/              ← DRR HTML files land here (provided, empty)
  run.command  run.sh   ← provided launchers (chmod +x)
  AGENT.md              ← provided update contract (the local agent's rules)
  BUILD_SPEC.md         ← this file
  README.md             ← provided user docs
```

## 3. Data contract

Schema documented in `AGENT.md`. Key facts for the app:

- `categories[]`: `{id, name, pls, players[]}`
- `players[]`: `{id, name, tagline, pls, url, tags[], prominence 1|2|3, report{status, path, updated}}`
- `report.status` ∈ `"none" | "in_progress" | "ready"`; when `"ready"`, `report.path`
  is an app-relative HTML path and `report.updated` is UTC ISO.
- Top-level `updated` bumps on every data edit.
- Player ids are globally unique — build a flat index for search and routing.

## 4. Views & behavior

### 4.1 Shell

- Full-viewport dark app, no scrollbars in map views. Header bar (56px):
  - Left: app name **AI Landscape** + subtitle "last updated <relative time>"
    (from top-level `updated`).
  - Center: search input (see 4.5), width ~420px, `/` focuses it.
  - Right: live stats "17 categories · 189 players · N reports" (computed, not
    hardcoded) — clicking "N reports" opens a dropdown listing all ready reports.
- Below header: the stage (galaxy or orbit) + right side panel (4.4) + overlays.
- Starfield background on the stage: ~200 canvas stars, 2 parallax layers, subtle
  twinkle. Under `prefers-reduced-motion: reduce`, stars are static and all
  ambient animation (twinkle, orbiting, pulsing) stops; transitions become fades.

### 4.2 Galaxy view (home, route `#/`)

- All categories as **suns**: filled circle + soft radial glow in the category
  color, radius ∝ `14 + 3·sqrt(playerCount)` px (clamp sensibly).
- Layout: golden-angle spiral — node *k* at angle `k·137.508°`, radius
  `R·sqrt(k+0.6)` — centered, scaled to fit the viewport, then 30–60 iterations of
  simple pairwise overlap relaxation so labels never collide. Deterministic (no
  randomness in positions) so the map is stable between visits.
- **Every sun shows its name label always** (12–13px, primary ink, on a subtle
  dark pill for legibility). Below the name, a muted count "12 players". Labels are
  mandatory — the palette's CVD safety assumes color is never the only identity
  channel.
- A small dot-badge on a sun when any of its players has a ready report; pulsing
  amber ring when any is `in_progress`.
- Hover: sun brightens (~1.15× scale, stronger glow), cursor pointer, tooltip with
  the first sentence of the category `pls`.
- Click / Enter: zoom transition into orbit view (`#/cat/<id>`) — scale+fade the
  galaxy out, orbit in, ~350 ms ease-in-out (skip under reduced motion).
- Suns are keyboard-focusable (`tabindex=0`, `role=link`, `aria-label`), focus ring
  = 2px white ring offset 2px.

### 4.3 Orbit view (route `#/cat/<id>`)

- The category as a central sun (its color, ~64px + glow) with the category name
  under it. Clicking the sun (or an ⓘ) opens the side panel with the **category
  PLS** (same panel as players, category flavor).
- Players orbit on **three rings by prominence**: 3 → inner, 2 → middle, 1 →
  outer. Even angular distribution per ring with a deterministic per-ring phase
  offset; ring radii scale to viewport (keep everything on screen at 13" laptop).
- Player nodes: circle in the category color — radius 22/17/13 px by prominence —
  with **name label always visible** beneath (11–12px, ink, dark pill). Node fill
  at 85% opacity, 1.5px brighter stroke.
- Report-status glyph on each node (icon + `title`, never color alone):
  - `none`: nothing
  - `in_progress`: small amber pulsing ring + "…" badge
  - `ready`: small filled dot in status-good green + ✓ badge
- Ambient motion: rings rotate very slowly (inner 90s/rev, alternating direction
  per ring); rotation pauses while any node is hovered/focused, and permanently
  under reduced motion.
- Hover: node scales 1.15×, tagline appears in tooltip. Click / Enter: open side
  panel (`#/player/<id>`). Hit target ≥ 40px even for small nodes (transparent
  halo).
- Breadcrumb top-left of stage: `← Galaxy / <Category>` (clickable), Esc also
  returns to galaxy (when no panel/overlay open).
- Prev/next category chevrons at stage edges (nice-to-have).

### 4.4 Player panel (route `#/player/<id>`)

Right-side drawer, 400px (100% width on narrow windows), slides over the orbit
view (which stays visible and dims 20%). Focus moves into it; Esc or ✕ closes back
to the orbit route. Contents top-to-bottom:

1. Category chip (color dot + category name, clickable → orbit).
2. **Player name** (22px semibold) + tagline (muted).
3. Tag chips + prominence label ("category leader" / "established" / "notable newcomer").
4. PLS paragraph (16px/1.6). Text always in ink tokens, never in the category color.
5. Official link (opens new tab, `rel="noopener"`).
6. **Report block** — the core loop, by `report.status`:
   - `none`: muted line "No deep report yet." + primary button
     **"Copy deep-research prompt"** → prompt modal (4.6).
   - `in_progress`: amber badge "Research in progress…" (pulse) + "started
     <relative time>" if derivable + ghost button "Re-copy prompt".
   - `ready`: **"Open report"** primary button + "updated <date>" + ghost button
     "Copy refresh prompt" (same modal, refresh variant).
7. Footnote, muted, 12px: "Reports are generated by your local agent — see AGENT.md."

### 4.5 Search

- Fuzzy, instant (≤ 5 ms over 189 players — precompute lowercase haystacks).
  Match & rank: exact prefix > word-boundary prefix > substring > subsequence;
  search player names, taglines, tags, and category names.
- Dropdown under the input: up to 8 results — players (colored dot, name, muted
  category) and categories (dot + "category") — grouped, keyboard navigable
  (↑ ↓ Enter Esc), hover = same highlight. Enter navigates: player → its orbit
  view + open panel; category → orbit view.
- `/` focuses search from anywhere (unless typing in an input); Esc clears/blurs.

### 4.6 Prompt modal (the DRR handoff)

Centered modal (max-width 720px) over everything, dark surface `#161b2e`, hairline
border, focus-trapped, Esc/✕/backdrop closes. Contents:

- Title: "Deep-research prompt — <Player>".
- One-line hint: "Paste this to your local agent **in this folder**. The app will
  notice by itself when the report lands."
- Read-only `<textarea>` (~16 rows, 13px monospace) with the filled template below.
- **"Copy to clipboard"** primary button (`navigator.clipboard`, fallback to
  select+`execCommand`), flips to "Copied ✓" for 2s.

Template (fill `{{…}}` from data; `{{SIBLINGS}}` = up to 8 other player names in
the category, comma-separated; `{{DATE}}` = today, `{{VARIANT}}` = "Create" or
"Refresh" when a report already exists):

```
{{VARIANT}} a deep-research report for my AI Landscape app.

Working folder: this project (ai-landscape-wiki). Read AGENT.md first and follow
its DRR workflow and report style contract exactly.

Subject: {{PLAYER_NAME}} ({{PLAYER_URL}})
Landscape category: {{CATEGORY_NAME}} — alongside {{SIBLINGS}}
Player id: {{PLAYER_ID}}   ·   Today: {{DATE}}
Current one-liner in the app: "{{TAGLINE}}"

Steps (from AGENT.md, summarized):
1. In data/landscape.json set players[{{PLAYER_ID}}].report.status = "in_progress",
   bump top-level "updated", save. (This shows a spinner in my app.)
2. Research the CURRENT state: what it is, product & technology, market position
   vs the siblings above, business & pricing, developments from the last 6-12
   months, risks/limitations. Verify against multiple current sources.
3. Write a polished, self-contained HTML report to reports/{{PLAYER_ID}}.html
   following the style contract in AGENT.md (dark theme #101423, inline CSS only,
   no external requests, no JavaScript, sections + linked sources).
4. Update data/landscape.json for this player: report.status = "ready",
   report.path = "reports/{{PLAYER_ID}}.html", report.updated = UTC now;
   refresh the player's "pls"/"tagline" if stale; bump top-level "updated";
   validate with: python3 -m json.tool data/landscape.json > /dev/null
5. Save. My app polls the JSON and will announce the report on its own -
   do not edit index.html or any other file.
```

### 4.7 Report viewer (route `#/report/<id>`)

- Full-screen overlay (inset 24px, rounded 12px, shadow): header strip with player
  name, "updated <date>", "Open in new tab ↗" link, and ✕ (Esc closes → back to
  player panel route).
- Body: `<iframe sandbox="allow-same-origin" src="<report.path>?t=<updated>">`,
  100% size, no border, `#101423` backdrop while loading. If the file 404s, show
  an inline error card ("Report file missing — status says ready but
  reports/<id>.html wasn't found") instead of a broken frame.

### 4.8 Live updates — the "ping"

- Poll `data/landscape.json` every **5 s** (`fetch` with `?t=Date.now()`,
  `cache: "no-store"`); back off to 30 s when `document.hidden`, resume on
  visibility. On fetch error, silently retry (transient server restarts happen).
- Change detection: compare raw response text to the last text. On change: parse,
  swap state, re-render current view **preserving navigation/scroll/panel state**
  (if the open player/category vanished, fall back to galaxy with an info toast).
- Status-transition toasts (bottom-right stack, dark surface, colored left edge,
  auto-dismiss 8 s, ✕, max 4, `aria-live="polite"`):
  - → `in_progress`: "🔎 Research started: <Player>"
  - → `ready`: "✅ Report ready: <Player>" + **View** button → opens report viewer
  - new player/category appears: "✨ New in <Category>: <Player>"
- Also update header stats, sun/node badges, and any open panel in place. If the
  currently-open player's report just went ready, morph its report block live —
  this is the "agent pinged the app" moment, make it feel good (brief glow on the
  panel's report block).

### 4.9 Routing

Hash-based, handled on load + `hashchange`: `#/` galaxy · `#/cat/<id>` orbit ·
`#/player/<id>` orbit + panel · `#/report/<id>` orbit + panel + viewer. Unknown
ids → galaxy. Back/forward must behave sensibly; direct links deep-link correctly.

## 5. Design system (dark, space)

Define as CSS custom properties; use tokens everywhere (no stray hexes).

**Chrome & ink**

| Token | Value | Use |
|---|---|---|
| `--bg` | `#090c16` | page/stage backdrop (behind starfield) |
| `--surface` | `#101423` | panels, modals footprint, report bg |
| `--surface-2` | `#161b2e` | raised: modal, toast, tooltip, pills |
| `--ink` | `#f2f4fa` | primary text |
| `--ink-2` | `#a9aec2` | secondary text |
| `--muted` | `#7c8199` | labels, hints |
| `--hairline` | `#262b3d` | borders, dividers |
| `--ring` | `rgba(255,255,255,.10)` | subtle outlines |
| `--focus` | `#ffffff` | 2px focus ring |
| `--link` | `#7fb3f5` | links |

**Status (fixed, never reused as category colors; always icon + label)**

`--status-good: #0ca30c` (ready) · `--status-warn: #fab219` (in progress) ·
`--status-bad: #d03b3b` (errors).

**Category palette** — assigned by category index in JSON order, `index % 17`.
Validated (CVD + contrast) against `--surface` on 2026-07-16; **order is part of
the validation — do not reorder**, and keep labels always visible next to colored
marks:

```js
const PALETTE = ["#e16977","#0b7652","#b276d6","#766806","#3899ea","#b14325",
  "#12aa9c","#9c4591","#87a11e","#455fbd","#d5771d","#006da9","#d76799",
  "#277c20","#9481e8","#8e6301","#13a2cf"];
```

(Seed order: foundation-models, coding-agents, ai-app-builders, agent-frameworks,
mcp-tool-platforms, agent-memory, llm-gateways, inference-serving,
vector-databases, rag-frameworks, document-parsing, web-data, browser-agents,
observability-evals, ai-security, voice-ai, media-generation.)

**Type & bits:** `system-ui, -apple-system, "Segoe UI", sans-serif`; base 14px UI,
16px reading text; `tabular-nums` for stats. Radii: pills 999px, cards/modals
12px, buttons 8px. Buttons: primary = category color (or `--link` in neutral
contexts) with dark text if needed for ≥4.5:1, ghost = hairline border + ink.
Glows: layered `box-shadow`/canvas radial gradients in the category color at low
alpha — atmospheric, never neon-loud. Text never rendered in category colors;
colored dots/marks sit beside ink text.

## 6. Code quality

Single `<script type="module">`. Small pure functions; one `state` object
(`data`, `route`, `searchQuery`, `toasts`, `pollTimer`). Render functions per
view; event delegation; no globals leaking. Escape ALL data-derived strings
interpolated into HTML (`textContent` or an `esc()` helper) — the JSON is
agent-written, treat as untrusted. Comment the non-obvious (layout math, diffing).
Keep it readable — a future agent will edit this file.

## 7. Acceptance checklist — run every item before calling it done

Serve with `python3 -m http.server 8787` and verify:

1. Galaxy renders all 17 suns, labeled, no label collisions at 1280×800 and
   1512×982; layout identical across reloads.
2. Click Coding Agents → orbit shows its 12 players on prominence rings, labels
   readable, slow rotation; hover pauses it.
3. Click Claude Code → panel shows PLS, tags, link; "Copy deep-research prompt"
   modal opens; **Copy** puts the exact filled template on the clipboard
   (`{{…}}` all resolved, no leftover braces).
4. Search "qdrant" → result jumps to Vector Databases orbit with Qdrant's panel
   open. Search "voice" → shows Voice AI category + voice players. `/` focuses,
   arrows+Enter work.
5. Hash routes: reload on `#/player/qdrant` deep-links correctly; back button
   walks panel → orbit → galaxy.
6. **Simulated agent run (the ping):** with the app open, edit
   `data/landscape.json`: set `claude-code` report to
   `{"status":"in_progress","path":null,"updated":null}` → amber pulse + toast
   within ~5 s. Then create `reports/claude-code.html` (any valid self-contained
   test HTML) and set `{"status":"ready","path":"reports/claude-code.html",
   "updated":"<now>"}` → "Report ready" toast, badge flips, **View** opens the
   report in the iframe viewer, Esc unwinds. **Then revert both files** (status
   back to `"none"`, delete the test report).
7. Reduced motion: with `prefers-reduced-motion: reduce` emulated, nothing
   animates ambiently; app remains fully usable.
8. Keyboard-only pass: tab through suns → Enter → tab nodes → Enter → panel →
   modal focus trap → Esc unwinds each layer in order.
9. Zero console errors throughout; JSON poll shows no error spam while the
   server restarts.
10. `python3 -m json.tool data/landscape.json` passes (you haven't corrupted it),
    and the only file you added is `index.html` (plus chmod on the launchers) —
    every provided file is byte-identical.

Then run `./run.command` once to confirm the launcher opens the app.
