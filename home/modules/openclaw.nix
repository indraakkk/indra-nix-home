{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  homeDir = config.home.homeDirectory;
  claudeBin = "${homeDir}/.local/bin/claude";
  secretsDir = "${homeDir}/.secrets";
  tokenFile = "${secretsDir}/anthropic-oauth-token";
  authProfilesFile = "${homeDir}/.openclaw/agents/main/agent/auth-profiles.json";
in
{
  imports = [ inputs.nix-openclaw.homeManagerModules.openclaw ];

  programs.openclaw = {
    enable = true;
    package = lib.lowPrio pkgs.openclaw; # avoid node binary collision with nodejs_20
    documents = ./openclaw-documents;

    bundledPlugins = {
      summarize.enable = true;
      peekaboo.enable = isDarwin;
    };

    instances.default = {
      enable = true;
      appDefaults.enable = false;

      config = {
        gateway = {
          mode = "local";
          bind = "loopback";
          auth.token = "244a4964c6f007afbb5679a7af27fc707d4456c9afb4ffc35e2802b1ed31d26a";
        };

        models = {
          providers = {
            anthropic = {
              baseUrl = "https://api.anthropic.com";
              api = "anthropic-messages";
              auth = "oauth";
              models = [
                {
                  id = "claude-sonnet-4-6";
                  name = "Claude Sonnet 4.6";
                  reasoning = false;
                  input = [ "text" "image" ];
                  contextWindow = 1000000;
                  maxTokens = 16384;
                }
                {
                  id = "claude-opus-4-6";
                  name = "Claude Opus 4.6";
                  reasoning = true;
                  input = [ "text" "image" ];
                  contextWindow = 1000000;
                  maxTokens = 16384;
                }
              ];
            };
          };
        };

        channels.whatsapp.accounts.default.enabled = true;

        agents.defaults = {
          model.primary = "anthropic/claude-sonnet-4-6";
          contextTokens = 1000000;
          compaction.mode = "safeguard";
          maxConcurrent = 4;
          subagents.maxConcurrent = 8;
        };
      };
    };
  };

  # Activation: bridge Claude Code OAuth → OpenClaw auth-profiles.json
  # Reads OAuth credentials from macOS keychain (where Claude Code stores them)
  home.activation.setupOpenclawAuth = lib.hm.dag.entryAfter [ "writeBoundary" "installClaudeCode" ] ''
    set -e
    ${pkgs.coreutils}/bin/mkdir -p "${secretsDir}"
    ${pkgs.coreutils}/bin/mkdir -p "$(dirname "${authProfilesFile}")"

    OAUTH_JSON=$(
      /usr/bin/security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null \
        | ${pkgs.python3}/bin/python3 -c "
import json, sys
data = json.load(sys.stdin)
oauth = data['claudeAiOauth']
print(json.dumps({
  'access': oauth['accessToken'],
  'refresh': oauth['refreshToken'],
  'expires': oauth['expiresAt']
}))" 2>/dev/null \
        || true
    )

    if [ -n "$OAUTH_JSON" ]; then
      OAUTH_ACCESS=$(echo "$OAUTH_JSON" | ${pkgs.python3}/bin/python3 -c "import json,sys; print(json.load(sys.stdin)['access'])")
      OAUTH_REFRESH=$(echo "$OAUTH_JSON" | ${pkgs.python3}/bin/python3 -c "import json,sys; print(json.load(sys.stdin)['refresh'])")
      OAUTH_EXPIRES=$(echo "$OAUTH_JSON" | ${pkgs.python3}/bin/python3 -c "import json,sys; print(json.load(sys.stdin)['expires'])")

      # Save access token to secrets file
      echo "$OAUTH_ACCESS" > "${tokenFile}"
      ${pkgs.coreutils}/bin/chmod 600 "${tokenFile}"

      # Write auth-profiles.json with proper OAuth profile format
      cat > "${authProfilesFile}" << AUTHEOF
{
  "version": 1,
  "profiles": {
    "anthropic:claude-cli": {
      "type": "oauth",
      "provider": "anthropic",
      "access": "$OAUTH_ACCESS",
      "refresh": "$OAUTH_REFRESH",
      "expires": $OAUTH_EXPIRES
    }
  },
  "lastGood": {
    "anthropic": "anthropic:claude-cli"
  }
}
AUTHEOF
      ${pkgs.coreutils}/bin/chmod 600 "${authProfilesFile}"
      echo "OpenClaw: Anthropic OAuth credentials injected from Claude Code keychain"
    else
      echo "OpenClaw: No Claude Code OAuth token in keychain (run 'claude auth login' first)"
    fi
  '';
}
