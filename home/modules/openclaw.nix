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
in
{
  imports = [ inputs.nix-openclaw.homeManagerModules.openclaw ];

  # --- agenix secrets ---
  age.identityPaths = [ "${homeDir}/.ssh/id_github_indraakkk" ];

  age.secrets.openclaw-gateway-token.file = ../../secrets/openclaw-gateway-token.age;
  age.secrets.telegram-bot-token.file = ../../secrets/telegram-bot-token.age;
  age.secrets.anthropic-setup-token.file = ../../secrets/anthropic-setup-token.age;
  age.secrets.whatsapp-allow-from.file = ../../secrets/whatsapp-allow-from.age;
  age.secrets.telegram-allow-from.file = ../../secrets/telegram-allow-from.age;

  # --- openclaw config ---
  programs.openclaw = {
    enable = true;
    package = lib.lowPrio pkgs.openclaw;
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
          auth.token = {
            source = "env";
            provider = "string";
            id = "OPENCLAW_GATEWAY_TOKEN";
          };
        };

        models = {
          providers.anthropic = {
            baseUrl = "https://api.anthropic.com";
            api = "anthropic-messages";
            auth = "token";
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

        # allowFrom set to empty — patched by activation script after agenix decrypts
        channels.whatsapp.accounts.default = {
          enabled = true;
          dmPolicy = "allowlist";
          allowFrom = [];
        };

        channels.telegram = {
          tokenFile = config.age.secrets.telegram-bot-token.path;
          dmPolicy = "allowlist";
          allowFrom = [];
        };

        session.dmScope = "per-peer";

        agents.list = [
          {
            id = "art-up";
            default = true;
            identity = {
              name = "Art Up!";
              emoji = "⛏️";
            };
          }
        ];

        agents.defaults = {
          model.primary = "anthropic/claude-opus-4-6";
          contextTokens = 1000000;
          compaction.mode = "safeguard";
          maxConcurrent = 4;
          subagents.maxConcurrent = 8;
        };
      };
    };
  };

  # Force-overwrite openclaw.json to prevent .backup conflicts on switch.
  home.file.".openclaw/openclaw.json".force = true;

  # Force-overwrite document files so Home Manager can replace the writable copies
  # created by makeOpenclawDocsWritable with fresh symlinks on each activation.
  home.file.".openclaw/workspace/TOOLS.md".force = true;
  home.file.".openclaw/workspace/AGENTS.md".force = true;
  home.file.".openclaw/workspace/SOUL.md".force = true;
  home.file.".openclaw/workspace/IDENTITY.md".force = true;
  home.file.".openclaw/workspace/USER.md".force = true;
  home.file.".openclaw/workspace/HEARTBEAT.md".force = true;

  # Override the upstream document guard to a no-op. The guard fails activation
  # when it finds regular files where symlinks should be, but we intentionally
  # replace symlinks with writable copies in makeOpenclawDocsWritable.
  home.activation.openclawDocumentGuard = lib.mkForce (
    lib.hm.dag.entryBefore [ "writeBoundary" ] ""
  );

  # After linkGeneration, replace read-only Nix store symlinks with writable copies
  # so the OpenClaw agent can edit documents at runtime. Nix source remains the
  # source of truth — edits persist only until the next home-manager switch.
  home.activation.makeOpenclawDocsWritable = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    WORKSPACE="${homeDir}/.openclaw/workspace"
    for doc in TOOLS.md AGENTS.md SOUL.md IDENTITY.md USER.md HEARTBEAT.md; do
      target="$WORKSPACE/$doc"
      if [ -L "$target" ]; then
        real=$(${pkgs.coreutils}/bin/readlink -f "$target")
        ${pkgs.coreutils}/bin/rm "$target"
        ${pkgs.coreutils}/bin/cp "$real" "$target"
        ${pkgs.coreutils}/bin/chmod u+w "$target"
      fi
    done
  '';

  # Activation: patch allowFrom from agenix secrets + write auth-profiles.json
  home.activation.setupOpenclawSecrets = lib.hm.dag.entryAfter [ "writeBoundary" "mountSecrets" ] ''
    OC_JSON="${homeDir}/.openclaw/openclaw.json"
    AUTH_PROFILES="${homeDir}/.openclaw/agents/main/agent/auth-profiles.json"
    ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "$AUTH_PROFILES")"

    # Patch openclaw.json from agenix secrets using jq
    if [ -f "$OC_JSON" ]; then
      GW_TOKEN_FILE="${config.age.secrets.openclaw-gateway-token.path}"
      WA_ALLOW="${config.age.secrets.whatsapp-allow-from.path}"
      TG_ALLOW="${config.age.secrets.telegram-allow-from.path}"

      # Patch gateway auth token: read value from agenix secret and inline it
      if [ -f "$GW_TOKEN_FILE" ]; then
        GW_TOKEN=$(${pkgs.coreutils}/bin/cat "$GW_TOKEN_FILE" | ${pkgs.coreutils}/bin/tr -d '[:space:]')
        ${pkgs.jq}/bin/jq \
          --arg token "$GW_TOKEN" \
          '.gateway.auth.token = $token' \
          "$OC_JSON" > "$OC_JSON.tmp" && \
          ${pkgs.coreutils}/bin/mv "$OC_JSON.tmp" "$OC_JSON"
        echo "OpenClaw: gateway token patched from agenix secret"
      fi

      # Patch telegram tokenFile: resolve the agenix path so OpenClaw can read it
      TG_TOKEN_FILE="${config.age.secrets.telegram-bot-token.path}"
      if [ -f "$TG_TOKEN_FILE" ]; then
        ${pkgs.jq}/bin/jq \
          --arg path "$TG_TOKEN_FILE" \
          '.channels.telegram.tokenFile = $path' \
          "$OC_JSON" > "$OC_JSON.tmp" && \
          ${pkgs.coreutils}/bin/mv "$OC_JSON.tmp" "$OC_JSON"
        echo "OpenClaw: telegram tokenFile patched to resolved path"
      fi

      if [ -f "$WA_ALLOW" ] && [ -f "$TG_ALLOW" ]; then
        WA_NUM=$(${pkgs.coreutils}/bin/cat "$WA_ALLOW" | ${pkgs.coreutils}/bin/tr -d '[:space:]')
        TG_ID=$(${pkgs.coreutils}/bin/cat "$TG_ALLOW" | ${pkgs.coreutils}/bin/tr -d '[:space:]')

        ${pkgs.jq}/bin/jq \
          --arg wa "$WA_NUM" \
          --arg tg "$TG_ID" \
          '.channels.whatsapp.accounts.default.allowFrom = [$wa] |
           .channels.telegram.allowFrom = [$tg]' \
          "$OC_JSON" > "$OC_JSON.tmp" && \
          ${pkgs.coreutils}/bin/mv "$OC_JSON.tmp" "$OC_JSON"
        echo "OpenClaw: allowFrom patched from agenix secrets"
      fi
    fi

    # Write auth-profiles.json from setup token
    SETUP_TOKEN_FILE="${config.age.secrets.anthropic-setup-token.path}"
    if [ -f "$SETUP_TOKEN_FILE" ]; then
      TOKEN=$(${pkgs.coreutils}/bin/cat "$SETUP_TOKEN_FILE")
      ${pkgs.coreutils}/bin/cat > "$AUTH_PROFILES" << AUTHEOF
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
    AUTHEOF
      ${pkgs.coreutils}/bin/chmod 600 "$AUTH_PROFILES"
      echo "OpenClaw: auth-profiles.json updated from agenix secret"
    fi
  '';
}
