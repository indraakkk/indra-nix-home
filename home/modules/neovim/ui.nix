{ ... }:
{
  colorschemes.catppuccin = {
    enable = true;
    settings = {
      flavour = "mocha";
      transparent_background = false;
      integrations = {
        cmp = true;
        gitsigns = true;
        neotree = true;
        telescope.enabled = true;
        treesitter = true;
        which_key = true;
        indent_blankline.enabled = true;
        lsp_saga = true;
        lsp_trouble = true;
        native_lsp.enabled = true;
      };
    };
  };

  plugins = {
    lualine = {
      enable = true;
      settings = {
        options = {
          theme = "catppuccin";
          component_separators = {
            left = "";
            right = "";
          };
          section_separators = {
            left = "";
            right = "";
          };
          disabled_filetypes.statusline = [
            "neo-tree"
            "Trouble"
          ];
        };
        sections = {
          lualine_a = [ "mode" ];
          lualine_b = [ "branch" "diff" "diagnostics" ];
          lualine_c = [ "filename" ];
          lualine_x = [ "encoding" "fileformat" "filetype" ];
          lualine_y = [ "progress" ];
          lualine_z = [ "location" ];
        };
      };
    };

    bufferline = {
      enable = true;
      settings.options = {
        diagnostics = "nvim_lsp";
        offsets = [
          {
            filetype = "neo-tree";
            text = "File Explorer";
            highlight = "Directory";
            separator = true;
          }
        ];
      };
    };

    indent-blankline = {
      enable = true;
      settings = {
        indent.char = "│";
        scope.enabled = true;
        exclude = {
          buftypes = [ "nofile" "terminal" ];
          filetypes = [
            "help"
            "terminal"
            "neo-tree"
            "Trouble"
            "dashboard"
          ];
        };
      };
    };

    web-devicons.enable = true;
  };
}
