# AI Landscape

A local interactive map of the AI tooling ecosystem — 17 categories as suns in a
galaxy, 189 players in orbit around them. Click a category, click a player, read a
plain-language summary; when you want depth, the app hands you a research prompt
for your local agent, and lights up on its own when the finished report lands.

Seed data researched 2026-07-16.

## One-time setup: build the app

The app itself (`index.html`) is built by your local coding agent from the spec in
this folder. Open your agent (Claude Code or similar) **in this folder** and paste:

```
Read BUILD_SPEC.md in this folder end to end, then build the AI Landscape
dashboard exactly as specified, as a single index.html. The researched seed data
already exists at data/landscape.json (17 categories, 189 players) — do not
regenerate or restructure it, and keep AGENT.md and the run scripts intact.
chmod +x run.command run.sh. Verify every item on the acceptance checklist in
BUILD_SPEC.md §7 — including the simulated-report test — then launch with
./run.command and confirm the app opens.
```

## Daily use

1. Double-click **`run.command`** (or `./run.sh`). The app opens at
   `http://localhost:8787`.
2. Explore: click a sun → its orbit → a player → read the summary. `/` to search.
3. Want depth on a player? **Copy deep-research prompt** → paste it to your local
   agent (opened in this folder). Keep the app running.
4. The agent flips the player to "researching…" within seconds, and when it
   finishes you get a toast — **Report ready** — and the report opens right inside
   the app. No refresh needed; the app watches its own data file.

## How the pieces fit

| File | Role |
|---|---|
| `index.html` | The app (built from `BUILD_SPEC.md`) |
| `data/landscape.json` | All categories/players/report statuses — the app polls this |
| `reports/*.html` | Deep-research reports, one per player |
| `AGENT.md` | The contract your local agent follows for every update |
| `BUILD_SPEC.md` | Full build spec (also the app's design reference) |
| `run.command` / `run.sh` | Launchers (local web server on port 8787) |

Updating the landscape itself works the same way as reports: ask your agent (in
this folder) to add/refresh categories or players per `AGENT.md` — the app picks
up changes live.

## Troubleshooting

- **Blank page / "needs a local server"** — you opened `index.html` directly.
  Browsers block data loading from `file://`; use `run.command`.
- **Port 8787 busy** — `PORT=8899 ./run.sh` (any free port).
- **`run.command` "can't be opened"** — `chmod +x run.command run.sh`, or
  right-click → Open the first time (Gatekeeper).
- **Player stuck on "researching…"** — the agent run died mid-flight. Ask it to
  finish, or set that player's `report.status` back to `"none"` in
  `data/landscape.json`.
- **`python3` missing** — install Xcode Command Line Tools, or serve with any
  static server from this folder (`npx serve -l 8787 .`).
