#!/usr/bin/env bash
set -euo pipefail
# Generate a long-lived Anthropic setup token via Claude Code and configure OpenClaw.
# Usage: bin/oc-refresh-auth.sh
#
# Runs 'claude setup-token', saves to ~/.secrets/anthropic-setup-token,
# writes auth-profiles.json, and restarts the gateway.

SECRETS_DIR="$HOME/.secrets"
TOKEN_FILE="$SECRETS_DIR/anthropic-setup-token"
AUTH_PROFILES="$HOME/.openclaw/agents/main/agent/auth-profiles.json"
CLAUDE_BIN="$HOME/.local/bin/claude"

mkdir -p "$SECRETS_DIR"
mkdir -p "$(dirname "$AUTH_PROFILES")"

echo "Running 'claude setup-token' (opens browser)..."
TOKEN=$("$CLAUDE_BIN" setup-token 2>&1 \
  | grep -oE 'sk-ant-oat01-[A-Za-z0-9_-]+' \
  | tail -1)

if [ -z "$TOKEN" ]; then
  echo "Error: Failed to extract setup token." >&2
  exit 1
fi

echo -n "$TOKEN" > "$TOKEN_FILE"
chmod 600 "$TOKEN_FILE"

cat > "$AUTH_PROFILES" << EOF
{
  "version": 1,
  "profiles": {
    "anthropic:setup-token": {
      "type": "token",
      "provider": "anthropic",
      "token": "$TOKEN"
    }
  },
  "lastGood": {
    "anthropic": "anthropic:setup-token"
  }
}
EOF
chmod 600 "$AUTH_PROFILES"

echo "Restarting OpenClaw gateway..."
openclaw gateway stop 2>/dev/null || true
sleep 2
launchctl bootstrap "gui/$(id -u)" ~/Library/LaunchAgents/ai.openclaw.gateway.plist 2>/dev/null || true
sleep 3

echo "Done. Setup token saved and gateway restarted."
openclaw health
