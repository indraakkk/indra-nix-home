{
  config,
  lib,
  pkgs,
  ...
}:
let
  claudeBin = "${config.home.homeDirectory}/.local/bin";
  claudeData = "${config.home.homeDirectory}/.local/share/claude";
in
{
  # Add claude binary to PATH (native installer puts it in ~/.local/bin)
  home.sessionPath = lib.mkAfter [ claudeBin ];

  # Install Claude Code using native installer (supports auto-updates)
  home.activation.installClaudeCode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -x "${claudeBin}/claude" ]; then
      echo "Installing Claude Code (stable channel)..."
      export PATH="${pkgs.curl}/bin:${pkgs.coreutils}/bin:${pkgs.bash}/bin:${pkgs.perl}/bin:${pkgs.gnutar}/bin:${pkgs.gzip}/bin:$PATH"
      ${pkgs.curl}/bin/curl -fsSL https://claude.ai/install.sh | ${pkgs.bash}/bin/bash -s stable
      echo "Claude Code installed successfully."
    else
      echo "Claude Code already installed, skipping (auto-updates enabled)."
    fi
  '';
}
