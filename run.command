#!/bin/zsh
# AI Landscape — double-click launcher (macOS)
# Serves the app folder over localhost and opens the browser.
cd "$(dirname "$0")"
PORT="${PORT:-8787}"

# If the port is already serving, just open the browser.
if lsof -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  open "http://localhost:$PORT"
  exit 0
fi

( sleep 1; open "http://localhost:$PORT" ) &
echo "AI Landscape running at http://localhost:$PORT  (Ctrl-C to stop)"
exec python3 -m http.server "$PORT"
