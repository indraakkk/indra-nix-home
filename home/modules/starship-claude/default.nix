{
  config,
  lib,
  pkgs,
  ...
}:
let
  homeDir = config.home.homeDirectory;
in
{
  # jq is required by the starship-claude script at runtime
  # starship is already provided by programs.starship.enable in shell.nix
  home.packages = [ pkgs.jq ];

  # Install the starship-claude statusline script
  home.file.".local/bin/starship-claude" = {
    source = ./starship-claude.sh;
    executable = true;
  };

  # Install the Starship config for Claude's statusline (separate from system starship)
  home.file.".claude/starship.toml" = {
    source = ./starship.toml;
  };

  # Patch settings.json to configure the statusLine (preserves all other fields)
  home.activation.configureClaudeStatusLine =
    lib.hm.dag.entryAfter [ "writeBoundary" "installClaudeCode" ] ''
      CLAUDE_SETTINGS="${homeDir}/.claude/settings.json"

      if [ ! -f "$CLAUDE_SETTINGS" ]; then
        echo '{}' > "$CLAUDE_SETTINGS"
      fi

      ${pkgs.jq}/bin/jq '
        .statusLine = {
          "type": "command",
          "padding": 0,
          "command": "~/.local/bin/starship-claude"
        }
        | .enabledPlugins["starship-claude@starship-claude"] = true
        | .extraKnownMarketplaces["starship-claude"] = {
            "source": {
              "source": "github",
              "repo": "martinemde/starship-claude"
            }
          }
      ' "$CLAUDE_SETTINGS" > "$CLAUDE_SETTINGS.tmp" && \
        mv "$CLAUDE_SETTINGS.tmp" "$CLAUDE_SETTINGS"

      echo "Claude settings: statusLine configured for starship-claude"
    '';
}
