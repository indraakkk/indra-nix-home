{ ... }:
{
  plugins = {
    toggleterm = {
      enable = true;
      settings = {
        direction = "horizontal";
        shell = "fish";
        size = ''
          function(term)
            if term.direction == "horizontal" then
              return math.floor(vim.o.lines * 0.3)
            elseif term.direction == "vertical" then
              return math.floor(vim.o.columns * 0.5)
            end
          end
        '';
        open_mapping = "[[<C-\\>]]";
        hide_numbers = true;
        shade_terminals = true;
        start_in_insert = true;
        insert_mappings = true;
        terminal_mappings = true;
        persist_size = true;
      };
    };

    which-key.settings.spec = [
      {
        __unkeyed-1 = "<leader>tt";
        __unkeyed-2 = "<cmd>1ToggleTerm direction=horizontal<CR>";
        desc = "Toggle Terminal (bottom)";
      }
      {
        __unkeyed-1 = "<leader>tv";
        __unkeyed-2 = "<cmd>2ToggleTerm direction=vertical<CR>";
        desc = "Toggle Terminal (right)";
      }
      {
        __unkeyed-1 = "<leader>tf";
        __unkeyed-2 = "<cmd>3ToggleTerm direction=float<CR>";
        desc = "Toggle Terminal (float)";
      }
    ];
  };

  # Terminal mode keymaps
  keymaps = [
    # Navigate out of terminal with Ctrl+hjkl
    {
      mode = "t";
      key = "<C-h>";
      action = "<C-\\><C-n><C-w>h";
      options.desc = "Navigate left from terminal";
    }
    {
      mode = "t";
      key = "<C-j>";
      action = "<C-\\><C-n><C-w>j";
      options.desc = "Navigate down from terminal";
    }
    {
      mode = "t";
      key = "<C-k>";
      action = "<C-\\><C-n><C-w>k";
      options.desc = "Navigate up from terminal";
    }
    {
      mode = "t";
      key = "<C-l>";
      action = "<C-\\><C-n><C-w>l";
      options.desc = "Navigate right from terminal";
    }
    # Double-Esc to exit terminal mode (single Esc goes to the terminal app)
    {
      mode = "t";
      key = "<Esc><Esc>";
      action = "<C-\\><C-n>";
      options.desc = "Exit terminal mode";
    }
  ];
}
