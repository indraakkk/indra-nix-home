{ lib, pkgs, ... }:
let
  inherit (lib) mkDefault;
in
{
  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "nix-env";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
          sha256 = "069ybzdj29s320wzdyxqjhmpm9ir5815yx6n522adav0z2nz8vs4";
        };
      }
    ];
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      command_timeout = 1000;
      cmd_duration = {
        format = " [$duration]($style) ";
        style = "bold #EC7279";
        show_notifications = false;
      };
      battery = {
        full_symbol = "🔋 ";
        charging_symbol = "⚡️ ";
        discharging_symbol = "💀 ";
      };
      nodejs = {
        format = "via [🤖 $version](bold green) ";
      };
    };
  };

  programs.bash.enable = mkDefault true;
}
