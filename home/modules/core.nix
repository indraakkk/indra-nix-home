{ config, lib, ... }:
let
  inherit (lib) mkDefault;
in {
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  xdg.enable = mkDefault true;

  home.sessionVariables = mkDefault {
    EDITOR = "vim";
    SHELL = "fish";
  };

  home.sessionPath = mkDefault [ "$HOME/.local/bin" ];
}
