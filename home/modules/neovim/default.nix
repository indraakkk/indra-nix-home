{ ... }:
{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    imports = [
      ./globals.nix
      ./ui.nix
      ./navigation.nix
      ./lsp.nix
      ./completion.nix
      ./git.nix
      ./ai.nix
      ./terminal.nix
      ./treesitter.nix
    ];
  };
}
