{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkAfter optional;
  system = pkgs.stdenv.hostPlatform.system;
  unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
  basePackages = with pkgs; [
    bun
    direnv
    docker
    gh
    git
    git-filter-repo
    nixfmt
    nodejs_20
    python3
    terraform
    google-cloud-sdk
    tree
    uv
    yq
  ];
  hasDevenv = builtins.hasAttr "devenv" pkgs;
  devenvPackage = if pkgs.stdenv.hostPlatform.isDarwin then [ ] else optional hasDevenv pkgs.devenv;
in
{
  home.packages = mkAfter (basePackages ++ devenvPackage ++ [ unstable.biome ]);

  home.sessionPath = mkAfter [ "${config.home.homeDirectory}/.npm-global/bin" ];

  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm-global
  '';

  home.file.".npm-global/.keep".text = "";
  home.file.".npm-global/bin/.keep".text = "";

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.vscode = {
    enable = true;
    mutableExtensionsDir = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
    ];
  };

  # VS Code settings: merge font/ligature preferences into existing settings.json
  # without overwriting manually configured settings.
  # Uses Node.js because VS Code settings.json may contain JSONC (comments),
  # which jq cannot parse.
  home.activation.mergeVscodeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -e
    VSCODE_SETTINGS="$HOME/Library/Application Support/Code/User/settings.json"

    ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "$VSCODE_SETTINGS")"
    if [ ! -f "$VSCODE_SETTINGS" ]; then
      echo '{}' > "$VSCODE_SETTINGS"
    fi

    ${pkgs.nodejs_20}/bin/node -e '
      const fs = require("fs");
      const settingsPath = process.argv[1];

      function stripJsoncComments(str) {
        let result = "";
        let inString = false;
        for (let i = 0; i < str.length; i++) {
          if (str[i] === "\"" && (i === 0 || str[i - 1] !== "\\")) {
            inString = !inString;
            result += str[i];
          } else if (!inString && str.slice(i, i + 2) === "//") {
            while (i < str.length && str[i] !== "\n") i++;
            i--;
          } else if (!inString && str.slice(i, i + 2) === "/*") {
            i += 2;
            while (i < str.length - 1 && str.slice(i, i + 2) !== "*/") i++;
            i++;
          } else {
            result += str[i];
          }
        }
        return result.replace(/,(\s*[}\]])/g, "$1");
      }

      const content = fs.readFileSync(settingsPath, "utf8");
      const existing = JSON.parse(stripJsoncComments(content));

      const managed = {
        "editor.fontFamily": "FiraCode Nerd Font Mono, monospace",
        "editor.fontLigatures": true,
        "terminal.integrated.fontFamily": "FiraCode Nerd Font Mono"
      };

      const merged = { ...existing, ...managed };

      const existingJson = JSON.stringify(existing, null, "\t");
      const mergedJson = JSON.stringify(merged, null, "\t");

      if (existingJson !== mergedJson) {
        fs.writeFileSync(settingsPath, mergedJson + "\n");
        console.log("VS Code: font/ligature settings merged into settings.json");
      } else {
        console.log("VS Code: settings already up to date, no changes needed");
      }
    ' "$VSCODE_SETTINGS"
  '';

  # Corepack activation: Enables Node.js's built-in package manager management.
  # pnpm shims are installed into ~/.npm-global/bin so they're on PATH.
  # Choose a pnpm version via `corepack prepare pnpm@<version> --activate`.
  home.activation.setupCorepack = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -e

    # Path to Node.js from nix profile
    NODE_BIN="${pkgs.nodejs_20}/bin"
    COREPACK_BIN_DIR="${config.home.homeDirectory}/.npm-global/bin"

    # Enable corepack (creates shims for pnpm, yarn, etc.)
    if command -v "$NODE_BIN/corepack" >/dev/null 2>&1; then
      echo "Enabling corepack..."
      "$NODE_BIN/corepack" enable --install-directory "$COREPACK_BIN_DIR"
      echo "Corepack setup complete. Use corepack to activate pnpm."
    else
      echo "Warning: corepack not found at $NODE_BIN/corepack" >&2
    fi
  '';
}
