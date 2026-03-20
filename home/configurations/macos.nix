{ lib, pkgs, inputs, ... }:
let
  inherit (lib) mkAfter mkDefault mkIf;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  brewPrefix = "/opt/homebrew";
  brewBin = "${brewPrefix}/bin";
  brewSbin = "${brewPrefix}/sbin";
in {
  imports = [
    inputs.mac-app-util.homeManagerModules.default
  ];

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

}
