# indra-nix-home (minimal bootstrap)

This repository hosts a modular, Home Manager driven setup that mirrors the structure of [r17x/universe](https://github.com/r17x/universe) while keeping the footprint intentionally small.

## Layout

- `flake.nix` — entry point exposing reusable helpers and per-host Home Manager configs.
- `home/profiles/minimal.nix` — minimal profile wiring the common modules together.
- `home/modules/` — focused modules for core defaults, shell ergonomics, and developer tooling.
- `home/configurations/` — host-specific tweaks (currently macOS and Linux).

Detailed macOS (Apple Silicon) setup instructions live in `docs/getting-started-macos.md`.

## Usage

```bash
# Preview available outputs
nix flake show

# Apply on macOS
home-manager switch --flake ".#indra@macos"

# Apply on Linux
home-manager switch --flake ".#indra@linux"
```

Extend the configuration by adding new modules under `home/modules` and importing them from the relevant profile or host file.
