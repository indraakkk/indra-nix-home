# indra-nix-home

Modular Home Manager configuration for macOS (Apple Silicon) and Linux, inspired by [r17x/universe](https://github.com/r17x/universe).

## Layout

```
flake.nix                        # entry point — nixpkgs 25.11, home-manager, nix-openclaw
home/
  profiles/minimal.nix           # default profile wiring all modules
  modules/
    core.nix                     # state version, XDG, session vars
    shell.nix                    # fish + starship prompt
    dev-tools.nix                # node, python, bun, terraform, gcloud, direnv, vscode, biome
    claude.nix                   # Claude Code install & version pinning
    ghostty.nix                  # Ghostty terminal (Catppuccin Mocha theme)
    openclaw.nix                 # OpenClaw agent with Anthropic setup-token auth
  configurations/
    macos.nix                    # macOS-specific overrides
    linux.nix                    # Linux / WSL overrides
bin/
  new-flake.sh                  # interactive project scaffolding (gum TUI)
  oc-refresh-auth.sh            # refresh OpenClaw Anthropic setup token & restart gateway
templates/
  devenv/                        # flake + devenv template with DB & runtime selection
docs/
  getting-started-macos.md       # Apple Silicon setup guide
```

## Usage

```bash
# Preview available outputs
nix flake show

# Apply on macOS
home-manager switch --flake ".#indra@macos"

# Apply on Linux
home-manager switch --flake ".#indra@linux"

# Scaffold a new project from the devenv template
nix run .#new-flake
```

## OpenClaw

The `openclaw.nix` module configures an [OpenClaw](https://github.com/openclaw/nix-openclaw) agent with Anthropic API access using long-lived setup tokens.

```bash
# Generate / refresh the setup token
bin/oc-refresh-auth.sh

# Check gateway health
openclaw health
```
