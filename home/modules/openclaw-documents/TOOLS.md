# TOOLS.md - Local Notes

## Infrastructure

- **OpenClaw Gateway:** `http://127.0.0.1:18789`
- **Claude Max Proxy:** `http://127.0.0.1:3456`
- **Project root:** `/Users/indra/indra-nix-home`

## Service Control

- **Start:** `devenv up` (from project root)
- **Stop:** `oc-stop.sh`

## Dev Environment

- **Nix flake + devenv** for reproducible environments
- **Node 22**, npm
- **Git repo** on branch `master` (main branch: `main`)

## Custom Commands

### /browser
When user types `/browser`, open `https://myaccount.google.com` in `profile=openclaw` and snapshot it to verify the Google account (indrakoslab@gmail.com) is still logged in. Report the logged-in account name and email. If not logged in, alert the user. Always use `profile=openclaw` for all browser tasks unless the user says otherwise.
