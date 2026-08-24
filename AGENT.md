# AGENT.md — standing contract for maintaining AI Landscape

You are the local agent responsible for keeping this app's data and reports current.
This file is the contract. The app (`index.html`) polls `data/landscape.json` every
few seconds — **saving valid files here IS the notification**. You never need to
"ping" the app; flip statuses in the JSON and the UI reacts on its own.

## Files you may touch

| Path | What it is | Rules |
|---|---|---|
| `data/landscape.json` | The entire dataset the app renders | Edit values; never restructure the schema |
| `reports/<player-id>.html` | Deep-research reports, one per player | Create/replace freely; follow the style contract below |
| `README.md` | Human docs | Update if workflows change |

Never rename `id` fields — reports, URLs, and hash routes key off them.
Never touch `index.html` unless explicitly asked to change the app itself.

## Data schema (v1)

```jsonc
{
  "schema": 1,
  "name": "AI Landscape",
  "description": "…",
  "updated": "2026-07-16T18:00:00Z",        // bump on EVERY edit (UTC ISO)
  "categories": [
    {
      "id": "coding-agents",                 // kebab-case, permanent
      "name": "Coding Agents",
      "pls": "60–100 word plain-language summary of the category",
      "players": [
        {
          "id": "claude-code",               // kebab-case, permanent, globally unique
          "name": "Claude Code",
          "tagline": "≤ 8 words",
          "pls": "40–70 word plain-language summary",
          "url": "https://…",                // official site
          "tags": ["cli", "agentic"],        // 2–4 lowercase tags
          "prominence": 3,                   // 3 leader · 2 established · 1 newcomer/niche
          "report": {
            "status": "none",                // "none" | "in_progress" | "ready"
            "path": null,                    // "reports/<player-id>.html" when ready
            "updated": null                  // UTC ISO timestamp when ready
          }
        }
      ]
    }
  ]
}
```

## The deep-research report (DRR) workflow

When the user pastes you a research prompt for player X (the app generates these),
follow this lifecycle **exactly**:

**1. Announce start.** In `data/landscape.json`, set X's
`report.status = "in_progress"`, bump top-level `updated`, save.
→ The app shows a pulsing "researching…" badge on X within ~5 seconds.

**2. Research.** Web-search thoroughly and CURRENT (funding, releases,
acquisitions, pricing, competitors, controversies — last 6–12 months weighted
heaviest). Verify claims across sources; prefer primary sources. Note publication
dates.

**3. Write the report** to `reports/<player-id>.html` per the style contract below.

**4. Publish.** In `data/landscape.json`:
- `report.status = "ready"`, `report.path = "reports/<player-id>.html"`,
  `report.updated = "<UTC ISO now>"`
- Refresh the player's `pls` / `tagline` if your research showed them stale
- Bump top-level `updated`
- Validate before saving: `python3 -m json.tool data/landscape.json > /dev/null`

→ The app toasts "Report ready" and the player's node lights up. Done — no other
notification is needed or possible.

**If research fails or is aborted:** set status back to `"none"` so the UI doesn't
spin forever.

## Report style contract

Reports render inside the app in a sandboxed iframe (`sandbox="allow-same-origin"`
— **scripts will not run**). A report is a **dossier that teaches**: it orients a
non-AI researcher while giving an expert a short path to what matters — dressed in
the **"brief" aesthetic**, a calm, geometric, editorial dashboard of numbered
sections, stat tiles, badges, HTML/CSS diagrams, a check-your-understanding quiz,
and a reliability-rated source table. Every report must be:

### Hard rules (never break)

- **One self-contained HTML file.** All CSS inline in a `<style>` block. **No
  external requests of any kind** — no web fonts / Google Fonts `<link>`, no CDNs,
  no remote images. Use inline SVG if you need graphics. **No JavaScript** (it
  won't execute).
- **Dark theme, always.** Reports are dark regardless of the app's light/dark
  toggle.

### Design tokens (define as CSS `:root` custom properties, use everywhere)

```
--bg:#101423        page background
--card:#161b2e      tiles, cards, table header fill
--card2:#1a1f33     code/kbd chips, alt panels, note boxes
--ink:#e8eaf2       primary text
--muted:#9aa0b5     secondary text, leads, meta
--line:#262b3d      borders, hairlines, dividers
--link:#7fb3f5      links
--accent:<CATEGORY> the player's category color — see below
--good:#0ca30c  --warn:#fab219  --bad:#d03b3b   status/reliability
```

`--accent` = **the player's category color**, from the `PALETTE` in BUILD_SPEC.md
§5 indexed by the category's position in `landscape.json` (`PALETTE[index % 17]`);
it's also the color of that category's sun in the app header. Use the accent
*structurally but sparingly*: the kicker, section numbers + section-head left bar,
the H1, the header/footer rules, tile tick-bars, and table-header underline. Body
text stays in ink — never tint paragraphs with the accent.

### Typography

- `font-family: Futura, "Century Gothic", "Jost", system-ui, -apple-system,
  "Segoe UI", sans-serif;` — a geometric sans; renders as Futura on macOS with no
  external request. Body ~15px, `line-height:1.55`, `letter-spacing:.1px`.
- Headings weight 600, lightly tracked (`letter-spacing:.4px`); big stat numbers
  weight 700. Kickers/labels: uppercase, `letter-spacing:2–3px`, ~11–12px.
- `max-width:940px` centered wrap, generous padding (~34px 26px 60px). Radii
  12–16px. Optional chunky offset shadow (`0 3px 0 rgba(...,.15)`) on emphasis
  blocks. Collapse grids to one column under ~820px.

### Pedagogical spine (how to write — apply *within* the sections, don't add new ones)

The report teaches, it doesn't just list. Fold this into the sections below:

- **Orient, then deepen.** Open each major section with the smallest useful mental
  model in plain language, then add mechanism. Intuition before detail.
- **Comparisons clarify.** Where it helps, show both sides — before/after,
  naive-vs-actual, claimed-vs-demonstrated — as a before/after panel or table.
- **Group by conceptual dependency,** not by the order sources present things.
- **Tag fact vs interpretation inline.** Separate what a source states from your
  reading of it; label estimates as estimates; never claim what the material
  doesn't support.
- **Tensions are non-fawning.** Say where the subject is genuinely weak, what's
  unresolved or assumed, and what would have to be true for it to be wrong. No
  soft-pedalling.

### Required sections (all, in order — the spine merges in; only the quiz is new)

**Header** — a **kicker** (`AI LANDSCAPE · DEEP-RESEARCH REPORT`, accent, uppercase,
tracked) above an H1 = **player name**; a subline with the **tagline**, a **category
pill** (accent dot + name), and `report generated <date>`; 2px accent bottom rule.
Every section below wears a **numbered `.sec-head`** (4px accent left-bar, two-digit
number, H2) with an optional muted `.lead`.

- **§01 TL;DR** — 3–5 sentence executive summary a busy reader could stop at;
  accent-left callout.
- **§02 What it is** — plain-language deep dive; open with an optional,
  clearly-skippable beginner mental model ("what the world looks like without it"),
  then narrow to specifics. `<details>` is good for skippable depth.
- **§03 Product & technology** — how it works, capabilities, form factors;
  intuition first, then mechanism. Use a **diagram** for flow/architecture.
- **§04 Market position** — **name the siblings from its category**;
  differentiation; adoption/traction in **stat tiles** (rounded card + accent left
  tick-bar + big number + label + sub; grids of 2–4). A before/after comparison
  fits well here.
- **§05 Business** — company, funding/ownership, pricing; stat tiles for
  valuation / funding / pricing tiers.
- **§06 Recent developments** — dated timeline (last 6–12 months) as a two-column
  table; **badges** (`NEW` good, `Δ CHANGED` warn, `RUMOR` outline) where useful.
- **§07 Risks & limitations** — the tensions section: honest, non-fawning; ends
  with a `.note`/callout bottom line.
- **§08 Check your understanding** — five medium MCQs (see Quiz). Skip only if the
  player is too thin for five fair questions; if you skip, say so in one line.
- **§09 Sources & reliability** — a **source table** (*Source · Item ·
  Reliability*), reliability color-coded (**High** good / **Med** accent /
  **Low·est.** bad), every row linked, **access dates** noted; one-line reliability
  key. Footer: 2px accent top rule + muted meta.

### Diagrams & figures

- Reuse a small set of **HTML/CSS diagram patterns** — flow (requests/data/
  argument), before/after panels, labeled component cards, compact tables for
  mappings/toy data. **Never ASCII diagrams**; build them with semantic HTML+CSS.
- Label arrows and include example values when a diagram shows movement.
  **Caption every figure** so the point survives without seeing it. Inline SVG only
  (no remote images).

### Interactivity is CSS-only (the iframe runs no JS)

`sandbox="allow-same-origin"` has no `allow-scripts`, so **`<script>` silently does
nothing**. Build all interactivity with pure HTML/CSS: `<details>`/`<summary>` for
skippable depth, and hidden radio inputs with `:checked` sibling selectors for the
quiz.

### Quiz (§08) — five questions, JS-free

- **Feedback on selection:** a `:checked ~ .fb` rule reveals whether the option is
  right and *why* (the reasoning/path). Nothing shows before selection.
- **Ask about behavior, causality, trade-offs, contracts, or edge cases** — never a
  phrase pattern-matchable from the page.
- **Every distractor is a real misunderstanding** a reader could hold. No
  joke/impossible options, no "all/none of the above", no trivia.
- **Options comparable** in length, grammar, specificity, confidence — the correct
  one must not stand out.
- **Fixed but balanced order:** runtime shuffle needs JS, so fix the order at
  authoring time and **balance the correct position across the five** (not all "B").
- **No correctness leaks** — not via order, pre-click styling, `title`, or a11y
  text; a11y labels describe the option, not its correctness.

### Craft, accessibility & substance

- Escape material-derived text. Put any code/quoted block in `<pre><code>` and set
  `white-space:pre`/`pre-wrap` in CSS so newlines survive — verify in the saved file.
- Visible focus states on interactive elements; sufficient contrast; **no meaning
  by color alone** (pair a hue with a label/icon — e.g. reliability text, not just
  color).
- **Grounded.** Every non-obvious claim traceable to a source; prefer primary
  sources; state uncertainty plainly.
- Target 1,200–2,500 words (excluding quiz). Keep the file under ~300 KB.

### Validate before flipping to `ready`

Confirm: complete HTML document; **zero external requests** (no `<link>`/
`<script src>`/`@import`/remote `url()`/web fonts); the **quiz reveals feedback on
click with no JS** and leaks no correctness; every `<pre>` preserves whitespace;
focus/contrast hold; all sections present in order.

`reports/claude-science.html` demonstrates the brief visual system and token block;
the §08 quiz and diagram patterns above are authoritative and appear on the next
(re)generation. Mirror the token block and structure for new reports.

## Adding / editing players and categories

- **Add a player:** append to the category's `players` array following the schema
  (report block starts `{"status":"none","path":null,"updated":null}`). Keep ids
  kebab-case and globally unique.
- **Add a category:** append to `categories` with an `id`, `name`, `pls`, and
  `players`. The app assigns its color automatically (palette cycles past 17).
- **Retire a player:** remove its object; optionally delete its report file.
- Always: bump top-level `updated`, validate JSON, save.

## Player refresh scan (consuming the search-miss queue)

The app captures **search misses** — player/company/product names a user searched
for and did not find — in a client-side queue (browser `localStorage`, never in
`landscape.json`). The app stays static; turning those misses into entries is *your*
job when a user hands you the queue. They deliver it one of two ways:

- **Pasted prompt** — the app's About panel ("N queued" / ⓘ) generates a
  *refresh-scan prompt* listing the queued queries with counts and last-seen dates.
- **`misses.json`** — a download with shape
  `{schema:"ai-landscape-misses/1", generated, landscape_updated, misses:[{query,count,hits,first_seen,last_seen}]}`.

Either way, run this lifecycle for each queued query:

**1. Identify.** Resolve the query to a real product/company and its current state.
Search first — it may already be in the landscape under a different name (check
`name`, `tagline`, `tags`, and rename history) or be a typo; if so, it's not a gap.

**2. Vet against the inclusion bar.** Add it only if it clears all of:
- **Real & current** — a shipping product/company, verified against multiple recent
  sources (not vaporware, not defunct).
- **In scope** — belongs to the AI tooling landscape this app maps; fits an existing
  category (or clearly warrants a new one per *Adding a category*).
- **Recognizable** — a user in the landscape's audience would plausibly look for it;
  mainstream or a notable newcomer, not exhaustive long-tail.
- **Distinct** — not a duplicate/alias of an existing player.

**3. Add (if it passes).** Append a schema-clean player to the right category:
kebab-case globally-unique `id`, `name`, ≤8-word `tagline`, 40–70-word `pls`,
official `url`, 2–4 lowercase `tags`, `prominence` (3/2/1), and
`report:{"status":"none","path":null,"updated":null}`. Fetch a logo to
`assets/logos/<id>.png` (favicon-grade is fine; colored-bubble fallback if none).
Optionally generate its DRR report per the report contract. Counts are computed by
the app — you don't store them; just bump top-level `updated`.

**4. Decline (if it fails).** Do **not** add it. Record the decline with a one-line
reason (e.g. "already present as `<id>`", "out of scope", "unverifiable / no primary
source", "defunct") so the user sees why. Declines live in your reply, not the data.

**5. Finish.** Validate: `python3 -m json.tool data/landscape.json > /dev/null`. The
app polls the JSON and shows new players on its next scan (with a "✨ New in
&lt;Category&gt;" toast) — do **not** edit `index.html`. The user removes handled
entries from their queue (or you can tell them which cleared). Schema stays intact
throughout: the miss queue never enters `landscape.json`.

## Refresh runs

A "refresh" prompt for a player with an existing report = same lifecycle. Overwrite
the old report file, update `report.updated`, and refresh the `pls`. History is not
kept — the app always shows the latest report only.
