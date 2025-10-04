{ config, lib, pkgs, ... }:
let
  inherit (lib) mkAfter optional;
  basePackages = with pkgs; [
    bun
    direnv
    docker
    git
    nodejs_20
  ];
  hasDevenv = builtins.hasAttr "devenv" pkgs;
  devenvPackage =
    if pkgs.stdenv.hostPlatform.isDarwin
    then [ ]
    else optional hasDevenv pkgs.devenv;
in {
  home.packages = mkAfter (basePackages ++ devenvPackage);

  home.sessionPath = mkAfter [ "${config.home.homeDirectory}/.npm-global/bin" ];

  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm-global
  '';

  home.file.".npm-global/.keep".text = "";
  home.file.".npm-global/bin/.keep".text = "";

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
