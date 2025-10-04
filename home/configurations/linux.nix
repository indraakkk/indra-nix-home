{ lib, ... }:
let
  inherit (lib) mkDefault;
in {
  home.username = mkDefault "indra";
  home.homeDirectory = mkDefault "/home/indra";

  programs.fish.loginShellInit = mkDefault ''
    if test -d "$HOME/.nix-profile/etc/profile.d"
      for profileScript in $HOME/.nix-profile/etc/profile.d/*.sh
        source $profileScript
      end
    end
  '';
}
