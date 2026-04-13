{ ... }:
{
  plugins = {
    cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
        sources = [
          { name = "nvim_lsp"; }
          { name = "nvim_lsp_signature_help"; }
          { name = "luasnip"; }
          { name = "async_path"; }
          { name = "buffer"; }
        ];
        experimental.ghost_text = true;
        performance = {
          debounce = 60;
          fetching_timeout = 200;
          max_view_entries = 30;
        };
        window = {
          completion = {
            border = "rounded";
            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None";
            col_offset = -3;
            side_padding = 0;
          };
          documentation.border = "rounded";
        };
        formatting = {
          expandable_indicator = true;
          fields = [ "kind" "abbr" "menu" ];
        };
        snippet.expand = ''
          function(args) require('luasnip').lsp_expand(args.body) end
        '';
        mapping = {
          "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-e>" = "cmp.mapping.close()";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<C-b>" = "cmp.mapping.scroll_docs(-4)";
        };
      };
      cmdline = {
        "/" = {
          mapping.__raw = "cmp.mapping.preset.cmdline()";
          sources = [ { name = "buffer"; } ];
        };
        ":" = {
          mapping.__raw = "cmp.mapping.preset.cmdline()";
          sources = [
            { name = "buffer"; }
            { name = "async_path"; }
            {
              name = "cmdline";
              option.ignore_cmds = [ "Man" "!" ];
            }
          ];
        };
      };
    };

    luasnip = {
      enable = true;
    };

    nvim-autopairs = {
      enable = true;
    };

    lspkind = {
      enable = true;
      settings = {
        cmp = {
          enable = true;
          maxWidth = 24;
        };
      };
    };
  };
}
