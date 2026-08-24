# AI Landscape Wiki

An interactive map of the AI tooling ecosystem. Categories are suns in a galaxy and the tools ("players") orbit around them. Click a sun to open its orbit, click a player to read a plain-language summary, and when you want depth the app hands you a research prompt to run in your own coding agent, then lights up on its own when the finished report lands. It ships as a single self-contained `index.html` with no build step and no backend.

Live: **https://ai-landscape-wiki.vercel.app**

## What's inside

Right now the map covers **21 categories** and **242 players**, spanning foundation models, coding agents, model harnesses and orchestration, agent frameworks, vector databases, RAG, inference and serving, AI security, voice, media generation, and AI for life sciences, among others. A couple of players already ship a full deep-research report (Claude Science and Pi); the rest carry a short summary you can deepen on demand. All counts are computed live from `data/landscape.json`, so they grow as the data does rather than being pinned in this file.

## Run it locally

There is nothing to build. The finished app is in the repo.

1. Double-click **`run.command`**, or run `./run.sh` from a terminal. It serves the folder and opens `http://localhost:8787`.
2. Explore: click a sun, then a player, then read its summary. Press `/` to search, and use the light/dark toggle, the info (ⓘ) button, and the GitHub link in the top bar.
3. That is all. Everything is static, so any plain static web server works too (see Troubleshooting).

A server is needed only because browsers block a page from reading local data files over `file://`, and the app polls `data/landscape.json`. The launcher just serves the folder over `http://localhost` so that read succeeds.

## Deep-research reports: the agent in the loop

The app does not call any AI service itself. Depth is opt-in and runs through your own coding agent, such as Claude Code:

1. Open a player and click **Copy deep-research prompt**.
2. Paste it to your agent, running in this folder, and keep the app open.
3. The agent flips that player to "researching" within a few seconds, does the work, and writes a report into `reports/`.
4. When it finishes you get a **Report ready** toast and the report opens right inside the app. No refresh needed, because the app watches its own data file.

`AGENT.md` is the contract the agent follows for every update: the data schema, the report style, and the exact steps. `reports/claude-science.html` and `reports/pi.html` are worked examples of the house report style.

## Keep the map tuned to your world (fork and update)

This map is one curator's snapshot, and it is meant to be forked and kept current for the tools you actually care about. It is not meant to be re-pointed at a different field; it stays a map of AI tooling, tuned by you.

The built-in loop for that is the **search-miss queue**. When you search for a tool that is not on the map, the app quietly records the term in your browser (local storage only, never in the shipped data). Open the info (ⓘ) panel to review the queue and copy a **refresh-scan prompt**, then hand that to your agent. Following `AGENT.md`, it checks each missing tool against the inclusion bar, adds the ones that clear it with a clean entry and a logo, and tells you what it skipped and why. Adding a player, refreshing a stale summary, or generating a report all work the same way: ask your agent in this folder, and the app picks up the change on its next poll.

## What's in the repo

| Path | Role |
|---|---|
| `index.html` | The whole app: one self-contained file, no build step |
| `data/landscape.json` | Every category, player, and report status. The app polls this file |
| `reports/*.html` | Deep-research reports, one per player, self-contained |
| `assets/logos/` | Player logos (favicon-grade), shown on the orbit nodes |
| `AGENT.md` | The contract your agent follows for reports and data updates |
| `BUILD_SPEC.md` | How the app was originally built. Kept as design reference, not a setup step |
| `run.command` / `run.sh` | Launchers: a local static server on port 8787 |

## Troubleshooting

- **Blank page, or a "needs a local server" message:** you opened `index.html` directly. Browsers block data loading over `file://`, so use `run.command` or `./run.sh`.
- **Port 8787 is busy:** choose another port, for example `PORT=8899 ./run.sh`.
- **`run.command` "can't be opened":** run `chmod +x run.command run.sh`, or right-click the file and choose Open the first time (macOS Gatekeeper).
- **A player is stuck on "researching":** an agent run ended mid-flight. Ask it to finish, or set that player's `report.status` back to `"none"` in `data/landscape.json`.
- **No `python3`:** install the Xcode Command Line Tools, or serve the folder with any static server, for example `npx serve -l 8787 .`.

## Reference

`BUILD_SPEC.md` documents how the app was originally built and doubles as its design reference. You do not need it to run or use the app. `AGENT.md` is the live contract for anyone, human or agent, updating the data and reports. The seed data was first researched in July 2026 and has been kept current since.
