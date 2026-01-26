{ config, lib, pkgs, ... }:
let
  inherit (lib) mkDefault mkForce;
in {
  home.username = mkDefault "indra";
  home.homeDirectory = mkDefault "/home/indra";

  # Linux/WSL-specific overrides
  home.sessionVariables = {
    SHELL = "${config.home.homeDirectory}/.nix-profile/bin/fish";
    COLORTERM = "truecolor";
  };

  # Disable VS Code in WSL - use Windows VS Code instead
  programs.vscode.enable = mkForce false;

  # Linux-specific packages not in shared modules
  home.packages = with pkgs; [
    fira-code
    uv
    jq
  ];

  programs.fish.loginShellInit = mkDefault ''
    if test -d "$HOME/.nix-profile/etc/profile.d"
      for profileScript in $HOME/.nix-profile/etc/profile.d/*.sh
        fenv source $profileScript
      end
    end
  '';

  programs.fish.interactiveShellInit = ''
    # Ensure nix profile is sourced for interactive non-login shells (fallback)
    if not set -q __nix_profile_sourced
      if test -d "$HOME/.nix-profile/etc/profile.d"
        for profileScript in $HOME/.nix-profile/etc/profile.d/*.sh
          fenv source $profileScript 2>/dev/null
        end
      end
      set -gx __nix_profile_sourced 1
    end
    set -gx COLORTERM truecolor
  '';
}
