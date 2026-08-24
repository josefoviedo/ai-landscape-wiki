#!/usr/bin/env bash
# AI Landscape — terminal launcher (macOS/Linux)
cd "$(dirname "$0")"
PORT="${PORT:-8787}"

if command -v open >/dev/null 2>&1; then OPEN=open; else OPEN=xdg-open; fi

if lsof -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  "$OPEN" "http://localhost:$PORT"
  exit 0
fi

( sleep 1; "$OPEN" "http://localhost:$PORT" ) &
echo "AI Landscape running at http://localhost:$PORT  (Ctrl-C to stop)"
exec python3 -m http.server "$PORT"
