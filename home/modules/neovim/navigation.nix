{ ... }:
{
  plugins = {
    telescope = {
      enable = true;
      extensions = {
        fzf-native.enable = true;
        ui-select.enable = true;
      };
      keymaps = {
        "<leader>ff" = {
          action = "find_files";
          options.desc = "Find Files";
        };
        "<leader>fg" = {
          action = "live_grep";
          options.desc = "Find by Grep";
        };
        "<leader>fb" = {
          action = "buffers";
          options.desc = "Find Buffers";
        };
        "<leader>fh" = {
          action = "help_tags";
          options.desc = "Find Help";
        };
        "<leader>fr" = {
          action = "oldfiles";
          options.desc = "Find Recent Files";
        };
        "<leader>fd" = {
          action = "diagnostics";
          options.desc = "Find Diagnostics";
        };
        "<leader>fc" = {
          action = "colorscheme";
          options.desc = "Find Colorscheme";
        };
        "<leader>fk" = {
          action = "keymaps";
          options.desc = "Find Keymaps";
        };
      };
    };

    neo-tree = {
      enable = true;
      settings = {
        window = {
          position = "left";
          width = 30;
        };
        filesystem = {
          filtered_items = {
            visible = false;
            hide_dotfiles = false;
            hide_gitignored = true;
          };
          follow_current_file.enabled = true;
          use_libuv_file_watcher = true;
        };
        git_status.window.position = "float";
      };
    };

    which-key = {
      enable = true;
      settings = {
        delay = 300;
        spec = [
          # neo-tree
          {
            __unkeyed-1 = "<leader>e";
            __unkeyed-2 = "<cmd>Neotree toggle<CR>";
            desc = "Toggle File Explorer";
          }
          {
            __unkeyed-1 = "<leader>o";
            __unkeyed-2 = "<cmd>Neotree focus<CR>";
            desc = "Focus File Explorer";
          }

          # buffer management
          {
            __unkeyed-1 = "<leader>w";
            __unkeyed-2 = "<cmd>w<CR>";
            desc = "Save File";
          }
          {
            __unkeyed-1 = "<leader>bd";
            __unkeyed-2 = "<cmd>bdelete<CR>";
            desc = "Close Buffer";
          }
          {
            __unkeyed-1 = "<leader>bn";
            __unkeyed-2 = "<cmd>bnext<CR>";
            desc = "Next Buffer";
          }
          {
            __unkeyed-1 = "<leader>bp";
            __unkeyed-2 = "<cmd>bprevious<CR>";
            desc = "Previous Buffer";
          }

          # window splits
          {
            __unkeyed-1 = "<leader>sv";
            __unkeyed-2 = "<cmd>vsplit<CR>";
            desc = "Split Vertical";
          }
          {
            __unkeyed-1 = "<leader>sh";
            __unkeyed-2 = "<cmd>split<CR>";
            desc = "Split Horizontal";
          }

          # clear search highlight
          {
            __unkeyed-1 = "<leader>nh";
            __unkeyed-2 = "<cmd>nohlsearch<CR>";
            desc = "Clear Search Highlight";
          }

          # window resize
          {
            __unkeyed-1 = "<C-Up>";
            __unkeyed-2 = "<cmd>resize +2<CR>";
            desc = "Increase window height";
          }
          {
            __unkeyed-1 = "<C-Down>";
            __unkeyed-2 = "<cmd>resize -2<CR>";
            desc = "Decrease window height";
          }
          {
            __unkeyed-1 = "<C-Right>";
            __unkeyed-2 = "<cmd>vertical resize +2<CR>";
            desc = "Increase window width";
          }
          {
            __unkeyed-1 = "<C-Left>";
            __unkeyed-2 = "<cmd>vertical resize -2<CR>";
            desc = "Decrease window width";
          }

          # group labels
          {
            __unkeyed-1 = "<leader>f";
            group = "Find";
          }
          {
            __unkeyed-1 = "<leader>g";
            group = "Git";
          }
          {
            __unkeyed-1 = "<leader>l";
            group = "LSP";
          }
          {
            __unkeyed-1 = "<leader>c";
            group = "Claude / Code";
          }
          {
            __unkeyed-1 = "<leader>b";
            group = "Buffer";
          }
          {
            __unkeyed-1 = "<leader>s";
            group = "Split";
          }
          {
            __unkeyed-1 = "<leader>t";
            group = "Toggle";
          }
        ];
      };
    };

    tmux-navigator = {
      enable = true;
      settings.no_mappings = 0;
    };
  };
}
