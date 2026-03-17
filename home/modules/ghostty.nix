{
  pkgs,
  inputs,
  ...
}:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  system = pkgs.stdenv.hostPlatform.system;
  unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
in
{
  programs.ghostty = {
    enable = true;
    package =
      if isDarwin
      then unstable.ghostty-bin
      else unstable.ghostty;
    settings = {
      command = "/Users/indra/.nix-profile/bin/fish --login --interactive";

      font-family = "JetBrainsMono Nerd Font";
      font-size = 16;

      window-decoration = true;
      cursor-style = "bar";
      copy-on-select = true;

      keybind = [
        "shift+enter=text:\\n"
        "super+n=new_window"
        "super+t=new_tab"
        "super+w=close_tab"
        "super+d=new_split:down"
        "super+r=new_split:right"
        "super+[=previous_tab"
        "super+]=next_tab"
      ];

      palette = [
        "0=#45475a"
        "1=#f38ba8"
        "2=#a6e3a1"
        "3=#f9e2af"
        "4=#89b4fa"
        "5=#f5c2e7"
        "6=#94e2d5"
        "7=#a6adc8"
        "8=#585b70"
        "9=#f38ba8"
        "10=#a6e3a1"
        "11=#f9e2af"
        "12=#89b4fa"
        "13=#f5c2e7"
        "14=#94e2d5"
        "15=#bac2de"
      ];
      background = "#1e1e2e";
      foreground = "#cdd6f4";
      cursor-color = "#f5e0dc";
      cursor-text = "#11111b";
      selection-background = "#353749";
      selection-foreground = "#cdd6f4";
    };
  };
}
