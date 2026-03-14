# Devenv Template

Interactive generator for flake+devenv projects.

## Usage

```
nix run ~/indra-nix-home#new-flake -- <project-name>
```

Run it inside an empty project directory. It will interactively prompt for:

1. **Database** — PostgreSQL, MySQL, or None
   - If selected, prompts for a custom port
2. **Runtime** — Bun, Node, or pnpm

### Examples

```bash
# Local
mkdir my-app && cd my-app
nix run ~/indra-nix-home#new-flake -- my-app

# From GitHub
nix run github:indralukmana/indra-nix-home#new-flake -- my-app

# With registry alias (after: nix registry add indra ~/indra-nix-home)
nix run indra#new-flake -- my-app

# Copy raw template without substitution
nix flake init -t ~/indra-nix-home#devenv
```

### Generated Files

| File | When | Description |
|------|------|-------------|
| `flake.nix` | Always | Multi-system Nix flake loading devenv modules |
| `devenv.nix` | Always | Base config: packages, scripts, enterShell |
| `devenv-pg.nix` | PostgreSQL selected | PostgreSQL service + DATABASE_URL |
| `devenv-mysql.nix` | MySQL selected | MariaDB service + DATABASE_URL |
| `.envrc` | Always | direnv auto-activation |
| `.gitignore` | Always | Ignores .devenv/ .direnv/ |

### After Scaffolding

- `cd` into the project — direnv auto-activates
- Database starts automatically if selected
- Edit `devenv.nix` to add more packages or scripts
- Run `devenv up` to start configured processes
