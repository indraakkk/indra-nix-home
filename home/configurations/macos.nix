{ lib, pkgs, inputs, ... }:
let
  inherit (lib) mkAfter mkDefault mkIf optionals;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  system = pkgs.stdenv.hostPlatform.system;
  unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
  brewPrefix = "/opt/homebrew";
  brewBin = "${brewPrefix}/bin";
  brewSbin = "${brewPrefix}/sbin";
  brewGhosttyBin = "${brewBin}/ghostty";
  ghosttyWrapper = pkgs.writeShellScriptBin "ghostty" ''
    ghostty_bin=${brewGhosttyBin}

    if [ ! -x "$ghostty_bin" ]; then
      printf '%s\n' "ghostty not found at $ghostty_bin" >&2
      exit 1
    fi

    exec "$ghostty_bin" "$@"
  '';
in {
  home.username = mkDefault "indra";
  home.homeDirectory = mkDefault "/Users/indra";

  programs.fish.loginShellInit = mkAfter ''
    if type -q ${brewBin}/brew
      eval (${brewBin}/brew shellenv)
    end
  '';

  home.sessionVariables = mkAfter {
    HOMEBREW_PREFIX = brewPrefix;
    HOMEBREW_CELLAR = "${brewPrefix}/Cellar";
    HOMEBREW_REPOSITORY = brewPrefix;
  };

  home.sessionPath = mkAfter [
    brewBin
    brewSbin
  ];

  home.packages = mkAfter (
    (optionals (!isDarwin) [ unstable.ghostty ])
    ++ (optionals isDarwin [ ghosttyWrapper ])
  );

  launchd.agents.orbstack-autostart = mkIf isDarwin {
    enable = true;
    config = {
      Label = "dev.orbstack.autostart";
      ProgramArguments = [ "${brewBin}/orb" ];
      RunAtLoad = true;
      KeepAlive = false;
      EnvironmentVariables = { PATH = "${brewBin}:/usr/bin:/bin"; };
      StandardOutPath = "/tmp/orbstack-autostart.out";
      StandardErrorPath = "/tmp/orbstack-autostart.err";
    };
  };

  home.activation = mkIf isDarwin {
    ensureOrbstackDocker =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        set -e

        if command -v ${brewBin}/orb >/dev/null 2>&1; then
          ${brewBin}/orb >/dev/null 2>&1 || true

          if command -v docker >/dev/null 2>&1; then
            if docker context inspect orbstack >/dev/null 2>&1; then
              docker context use orbstack >/dev/null 2>&1 || true
            fi
          fi
        fi

        ORB_SOCK="$HOME/.orbstack/run/docker.sock"
        if [ -S "$ORB_SOCK" ]; then
          if [ ! -S /var/run/docker.sock ] || [ "$(readlink /var/run/docker.sock || true)" != "$ORB_SOCK" ]; then
            if command -v sudo >/dev/null 2>&1; then
              sudo ln -snf "$ORB_SOCK" /var/run/docker.sock || true
            fi
          fi
        fi
      '';
  };


  # ---------- Ghostty config (macOS) ----------
  # macOS Ghostty uses ~/Library/Application Support/com.mitchellh.ghostty/config
  home.file."Library/Application Support/com.mitchellh.ghostty/config" = mkIf isDarwin {
    force = true;
    text = ''
      # Shell
      command = /Users/indra/.nix-profile/bin/fish --login --interactive

      # Font
      font-family = JetBrainsMono Nerd Font
      font-size   = 16

      # UI & rendering
      window-decoration = true
      cursor-style      = bar
      copy-on-select    = true

      # Keybindings
      keybind = shift+enter=text:\n
      keybind = super+n=new_window
      keybind = super+t=new_tab
      keybind = super+w=close_tab
      keybind = super+d=new_split:down
      keybind = super+r=new_split:right
      keybind = super+[=previous_tab
      keybind = super+]=next_tab

      # Catppuccin Mocha (inlined)
      palette = 0=#45475a
      palette = 1=#f38ba8
      palette = 2=#a6e3a1
      palette = 3=#f9e2af
      palette = 4=#89b4fa
      palette = 5=#f5c2e7
      palette = 6=#94e2d5
      palette = 7=#a6adc8
      palette = 8=#585b70
      palette = 9=#f38ba8
      palette = 10=#a6e3a1
      palette = 11=#f9e2af
      palette = 12=#89b4fa
      palette = 13=#f5c2e7
      palette = 14=#94e2d5
      palette = 15=#bac2de
      background           = #1e1e2e
      foreground           = #cdd6f4
      cursor-color         = #f5e0dc
      cursor-text          = #11111b
      selection-background = #353749
      selection-foreground = #cdd6f4
    '';
  };

}
