{
  config,
  lib,
  pkgs,
  ...
}:
let
  claudeBin = "${config.home.homeDirectory}/.local/bin";
  claudeData = "${config.home.homeDirectory}/.local/share/claude";
  claudeVersion = "2.1.53"; # Pin version here for easy updates
in
{
  # Add claude binary to PATH (native installer puts it in ~/.local/bin)
  home.sessionPath = lib.mkAfter [ claudeBin ];

  # Install/update Claude Code using native installer (idempotent)
  home.activation.installClaudeCode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        export PATH="${pkgs.curl}/bin:${pkgs.coreutils}/bin:${pkgs.bash}/bin:${pkgs.perl}/bin:${pkgs.gnutar}/bin:${pkgs.gzip}/bin:$PATH"

        # Only install if the pinned version binary doesn't exist yet
        if [ ! -f "${claudeData}/versions/${claudeVersion}" ]; then
          echo "Installing/updating Claude Code to version ${claudeVersion}..."
          ${pkgs.curl}/bin/curl -fsSL https://claude.ai/install.sh | ${pkgs.bash}/bin/bash -s ${claudeVersion}
        else
          echo "Claude Code ${claudeVersion} already installed, skipping."
        fi

        # Delete old versions (keep only the pinned version)
        for version in "${claudeData}/versions/"*; do
          if [ -f "$version" ] && [ "$(${pkgs.coreutils}/bin/basename "$version")" != "${claudeVersion}" ]; then
            echo "Removing old version: $version"
            ${pkgs.coreutils}/bin/rm -f "$version"
          fi
        done

        # Force symlink to pinned version
        if [ -f "${claudeData}/versions/${claudeVersion}" ]; then
          ${pkgs.coreutils}/bin/ln -sf "${claudeData}/versions/${claudeVersion}" "${claudeBin}/claude"
          echo "Claude Code ${claudeVersion} symlink updated."
        else
          echo "Warning: Claude Code ${claudeVersion} binary not found after install"
        fi

        # Set minimumVersion in Claude settings to prevent auto-update downgrades
        CLAUDE_SETTINGS="${config.home.homeDirectory}/.claude/settings.json"
        if [ -f "$CLAUDE_SETTINGS" ]; then
          ${pkgs.python3}/bin/python3 -c "
    import json, sys
    with open('$CLAUDE_SETTINGS', 'r') as f:
        s = json.load(f)
    s['minimumVersion'] = '${claudeVersion}'
    with open('$CLAUDE_SETTINGS', 'w') as f:
        json.dump(s, f, indent=2)
        f.write('\n')
    "
          echo "Claude settings: minimumVersion set to ${claudeVersion}"
        fi
  '';
}
