#!/usr/bin/env bash
set -euo pipefail

FLAKE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLAKE_TARGET="${1:-indra@macos}"

echo "Switching home-manager to #${FLAKE_TARGET}..."

# Clean up .backup files only for paths managed by home-manager
# These accumulate from previous switches and block subsequent ones
HM_PROFILE="$HOME/.local/state/nix/profiles/home-manager"
if [[ -L "$HM_PROFILE" ]]; then
  HM_GEN=$(readlink -f "$HM_PROFILE")
  HM_FILES_DIR="$HM_GEN/home-files"
  if [[ -d "$HM_FILES_DIR" ]]; then
    find "$HM_FILES_DIR" -type l | while read -r managed; do
      rel="${managed#"$HM_FILES_DIR"/}"
      backup="$HOME/${rel}.backup"
      if [[ -e "$backup" ]]; then
        rm -f "$backup"
        echo "  cleaned: ~/${rel}.backup"
      fi
    done
  fi
fi

home-manager switch --flake "${FLAKE_DIR}#${FLAKE_TARGET}" -b backup
