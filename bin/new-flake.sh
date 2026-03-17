#!/usr/bin/env bash
set -euo pipefail

# --- Args ---
if [[ $# -lt 1 ]]; then
  echo "Usage: new-flake <project-name>"
  echo ""
  echo "Run inside an empty directory to scaffold a flake+devenv project."
  exit 1
fi

PROJECT="$1"
echo ""
echo "Scaffolding project: $PROJECT"
echo ""

# --- Database selection ---
DB=$(gum choose --header "Select database" "PostgreSQL" "MySQL" "None")

DB_PORT=""
if [[ "$DB" != "None" ]]; then
  DEFAULT_PORT="5432"
  [[ "$DB" == "MySQL" ]] && DEFAULT_PORT="3306"
  DB_PORT=$(gum input --header "$DB port" --placeholder "$DEFAULT_PORT" --value "$DEFAULT_PORT")
fi

# --- Runtime selection ---
RUNTIME=$(gum choose --header "Select runtime" "Bun" "Node" "pnpm")

# --- Resolve template dir ---
# TEMPLATE_DIR is set by nix wrapper. Fallback for running directly from repo.
if [[ -z "${TEMPLATE_DIR:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  TEMPLATE_DIR="$SCRIPT_DIR/../templates/devenv"
fi

# --- In-place sed (gnused is provided by nix wrapper) ---
_sed() {
  sed -i "$@"
}

# --- Copy base files (--no-preserve=mode so nix store copies are writable) ---
cp --no-preserve=mode "$TEMPLATE_DIR/flake.nix" ./flake.nix
cp --no-preserve=mode "$TEMPLATE_DIR/devenv.nix" ./devenv.nix
cp --no-preserve=mode "$TEMPLATE_DIR/.envrc" ./.envrc
cp --no-preserve=mode "$TEMPLATE_DIR/gitignore" ./.gitignore

# --- Substitute runtime packages ---
case "$RUNTIME" in
  Bun)    PKGS="pkgs.bun" ;;
  Node)   PKGS="pkgs.nodejs_22" ;;
  pnpm)   PKGS="pkgs.nodejs_22\n    pkgs.pnpm" ;;
esac

_sed "s/__PROJECT__/$PROJECT/g" devenv.nix
_sed "s/__PACKAGES__/$PKGS/g" devenv.nix

# --- Add database module ---
MODULES="./devenv.nix"

if [[ "$DB" == "PostgreSQL" ]]; then
  cp --no-preserve=mode "$TEMPLATE_DIR/devenv-pg.nix" ./devenv-pg.nix
  _sed "s/__PROJECT__/$PROJECT/g; s/__PORT__/$DB_PORT/g" devenv-pg.nix
  MODULES="./devenv.nix ./devenv-pg.nix"
elif [[ "$DB" == "MySQL" ]]; then
  cp --no-preserve=mode "$TEMPLATE_DIR/devenv-mysql.nix" ./devenv-mysql.nix
  _sed "s/__PROJECT__/$PROJECT/g; s/__PORT__/$DB_PORT/g" devenv-mysql.nix
  MODULES="./devenv.nix ./devenv-mysql.nix"
fi

# Update flake.nix modules list if database was added
if [[ "$MODULES" != "./devenv.nix" ]]; then
  _sed "s|modules = \[ ./devenv.nix \];|modules = [ $MODULES ];|" flake.nix
fi

# --- Init git ---
if [[ ! -d .git ]]; then
  git init -q
fi
git add -A
direnv allow 2>/dev/null || true

# --- Done ---
echo ""
echo "✓ Project '$PROJECT' ready!"
echo "  Runtime: $RUNTIME"
[[ "$DB" != "None" ]] && echo "  Database: $DB on port $DB_PORT"
echo ""
echo "  cd $(pwd) to activate"
