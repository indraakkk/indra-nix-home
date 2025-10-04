# Getting Started on macOS (Apple Silicon / M4)

This guide walks through setting up the `indra-nix-home` Home Manager configuration on a macOS system powered by an Apple Silicon chip (M1–M4).

> ✅ Goal: manage your user environment declaratively with Nix + Home Manager, using the minimal configuration shipped in this repository.

---

## 1. Prerequisites

1. **macOS updates**: ensure you are running the latest macOS release supported by your hardware.
2. **Command Line Tools**: install Xcode Command Line Tools (CLT) for Git and compilers.
   ```bash
   xcode-select --install
   ```
3. **Rosetta (optional)**: if you need to run Intel-only binaries, install Rosetta 2.
   ```bash
   softwareupdate --install-rosetta --agree-to-license
   ```

---

## 2. Install Nix with flakes enabled

Use the Determinate Systems installer, which enables the `nix-command` and `flakes` features automatically:

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate
```

After installation, verify that flakes are enabled:

```bash
grep experimental-features ~/.config/nix/nix.conf
# experimental-features = nix-command flakes
```

If the file or entry is missing, append it manually:

```bash
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
```

---

## 3. Install required Homebrew apps

The macOS profile expects a couple of GUI/CLI tools to come from Homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"  # if Homebrew is not installed yet

brew update
brew install --cask ghostty
brew install --cask orbstack
```

Launch OrbStack once so it can finish its initial setup; the Home Manager module will take over afterwards.

---

## 4. Clone the configuration repo

```bash
cd ~
mkdir -p indra-nix-home
cd indra-nix-home

# If you have not cloned yet
# git clone git@github.com:yourname/indra-nix-home.git .

# Ensure the flake evaluates
nix flake show
```

The first run downloads and caches the pinned `nixpkgs` and `home-manager` inputs defined in `flake.lock`.

---

## 5. Apply the macOS Home Manager profile

The flake exposes a ready-made `indra@macos` configuration targeting `aarch64-darwin` (Apple Silicon). Apply it with:

```bash
home-manager switch --flake .#indra@macos
```

Home Manager will build the configuration and symlink the managed files into `~/.config/home-manager`. On first run you might be prompted to allow the `fish` shell in `/etc/shells` if it isn’t already present.

To make Fish your login shell:

```bash
chsh -s $(which fish)
```

---

## 6. Verify the environment

Open a new terminal session (Ghostty, iTerm2, or Terminal.app) and confirm the key tools:

```bash
fish --version
starship --version
node -v
bun -v
direnv --version
ghostty --version
docker context ls | grep '\*'   # active Docker context should be orbstack
orb status
ls -l /var/run/docker.sock
```

If the Starship prompt does not appear in Ghostty, make sure Ghostty uses `fish` as its default shell (Preferences → Shell).

---

If OrbStack reports that the daemon is stopped, run `orb` to start it manually and re-run `home-manager switch`.

---

## 7. Daily workflow

1. Edit modules in this repository (`home/modules`, `home/profiles`, etc.).
2. Re-build when you are ready:
   ```bash
   home-manager switch --flake .#indra@macos
   ```
3. Commit and push your changes:
   ```bash
   git add -A
   git commit -m "Describe your change"
   git push
   ```

On a new Mac, repeat steps 2–4—clone the repo and run `home-manager switch --flake .#indra@macos`.

---

## 8. Troubleshooting

- **OrbStack didn’t start**: run `launchctl kickstart gui/$(id -u)/dev.orbstack.autostart` or invoke `orb` manually; the launchd agent is installed as part of the Home Manager profile.
- **Docker CLI still points at `default`**: `docker context use orbstack` switches back; the activation hook attempts this automatically at build time.
- **`/var/run/docker.sock` missing**: the activation hook symlinks it to `~/.orbstack/run/docker.sock` when `sudo` is available. Create it manually otherwise: `sudo ln -snf ~/.orbstack/run/docker.sock /var/run/docker.sock`.
- **Fish plugin missing**: rerun `home-manager switch`; it installs the `lilyball/nix-env.fish` plugin and Starship prompt.

---

## 9. Next steps

- Launch Ghostty from Spotlight or `ghostty` in a shell; it is managed by Home Manager and updated with the rest of the configuration.
- Extend the configuration by adding new modules under `home/modules` and importing them from `home/profiles/minimal.nix`.
- Create optional profiles (e.g. `home/profiles/dev.nix`) when the configuration grows.

With these steps, Home Manager keeps Fish + Starship styling, OrbStack autostart, and Ghostty defaults in sync across your macOS (M4) workstations.
