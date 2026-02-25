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
    nixfmt
    nodejs_20
    terraform
    google-cloud-sdk
    tree
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
