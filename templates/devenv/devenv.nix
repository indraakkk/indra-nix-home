{ pkgs, ... }:

{
  packages = [
    __PACKAGES__
  ];

  enterShell = ''
    echo "__PROJECT__ dev environment"
  '';
}
