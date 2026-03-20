# Token-Lean Plan (Git-tracked Nix + Home Manager)

## 🎯 Goal

Recreate a reproducible development environment (Ubuntu, macOS, WSL) with **Nix + Home Manager**, tracked in a **Git repo**, installed using Determinate Systems installer. Includes:

* Node.js, Bun, Docker CLI, direnv, devenv (MySQL/Postgres)
* Fish shell + Starship prompt

---

## 🧠 Mental model

| Location                  | Purpose                                                                 |
| ------------------------- | ----------------------------------------------------------------------- |
| `~/indra-nix-home/`       | Your Git repo = **source of truth** (edit + push here)                  |
| `~/.config/home-manager/` | **Symlinked** target auto-managed by Home Manager — don’t edit manually |

`home-manager switch` builds your config and symlinks everything automatically.

---

## 🧩 Setup Steps

### 1️⃣ Install Nix (flakes on)

Use the Determinate Systems installer (**stable, fast, flakes-enabled**):

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate
```

Then confirm flakes enabled:

```bash
# ~/.config/nix/nix.conf
experimental-features = nix-command flakes
```

**Reference:**

* [https://determinate.systems/nix-installer/](https://determinate.systems/nix-installer/)
* [https://determinate.systems/blog/determinate-nix-installer/](https://determinate.systems/blog/determinate-nix-installer/)

---

### 2️⃣ Install Home Manager (flake-based)

```bash
nix run home-manager/master -- init --switch
```

Creates a starter flake under `~/.config/home-manager`, but we’ll manage it in our repo.
**Docs:** [https://github.com/nix-community/home-manager](https://github.com/nix-community/home-manager)

---

### 3️⃣ Create your repo

```bash
mkdir -p ~/indra-nix-home/home
cd ~/indra-nix-home
# Add the provided flake.nix and home/default.nix from our template
# Then commit it

git init
nix flake lock  # optional: lock versions
```

Push this to GitHub — this repo is your **portable configuration**.

---

### 4️⃣ Apply config (macOS / Ubuntu / WSL)

```bash
home-manager switch --flake ~/indra-nix-home#indra@host
```

Home Manager will symlink configs into `~/.config/home-manager` and set Fish + Starship.

Optional bootstrap to always use GitHub version:

```nix
# ~/.config/home-manager/flake.nix
{
  inputs.indra-nix-home.url = "github:you/indra-nix-home";
  outputs = inputs: inputs.indra-nix-home.outputs;
}
```

---

### 5️⃣ Docker group (Linux/WSL)

```bash
sudo groupadd docker 2>/dev/null || true
sudo usermod -aG docker "$USER"
newgrp docker
```

macOS: install Docker Desktop or Colima (HM only installs CLI).

**Refs:**

* [https://docs.docker.com/engine/install/linux-postinstall/](https://docs.docker.com/engine/install/linux-postinstall/)
* [https://docs.docker.com/engine/security/rootless/](https://docs.docker.com/engine/security/rootless/)

---

### 6️⃣ direnv + devenv for per-project DBs

In your project folder:

```bash
echo "use flake" > .envrc
direnv allow
```

Create `devenv.nix` (from our template) to enable MySQL/Postgres:

```bash
nix develop  # or devenv shell
devenv up    # starts databases
```

**Refs:**

* [https://devenv.sh/](https://devenv.sh/)
* [https://devenv.sh/reference/options/](https://devenv.sh/reference/options/)
* [https://direnv.net/docs/hook.html](https://direnv.net/docs/hook.html)

---

### 7️⃣ Daily workflow

```bash
# Edit configs in repo
$EDITOR ~/indra-nix-home/home/programs.nix

# Apply changes
home-manager switch --flake ~/indra-nix-home#indra@host

# Version & push
git add -A && git commit -m "update fish/starship config" && git push

# On another machine:
git clone https://github.com/you/indra-nix-home
home-manager switch --flake ./#indra@MacBook
```

---

### 8️⃣ Validate environment

```bash
node -v && bun -v && docker --version && fish -v && starship --version
```

Open a terminal, confirm the shell is Fish, and the prompt uses Starship.

---

## ✅ You now have

* Reproducible, cross-platform setup via Nix + Home Manager
* Fish + Starship terminal experience
* Node, Bun, Docker CLI, direnv, and devenv (MySQL + Postgres)

---

## 📚 References Summary

* Nix Installer: [https://determinate.systems/nix-installer/](https://determinate.systems/nix-installer/)
* Home Manager: [https://github.com/nix-community/home-manager](https://github.com/nix-community/home-manager)
* Nix manual (flakes): [https://nix.dev/manual/nix/2.25/development/experimental-features](https://nix.dev/manual/nix/2.25/development/experimental-features)
* devenv: [https://devenv.sh/](https://devenv.sh/)
* direnv: [https://direnv.net/](https://direnv.net/)
* Fish: [https://fishshell.com/](https://fishshell.com/)
* Starship: [https://starship.rs/](https://starship.rs/)
* Docker post-install: [https://docs.docker.com/engine/install/linux-postinstall/](https://docs.docker.com/engine/install/linux-postinstall/)
