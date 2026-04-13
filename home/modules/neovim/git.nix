{ ... }:
{
  plugins = {
    gitsigns = {
      enable = true;
      settings = {
        numhl = true;
        linehl = false;
        current_line_blame = false;
        current_line_blame_opts = {
          virt_text = true;
          virt_text_pos = "eol";
        };
        signs = {
          add.text = "│";
          change.text = "│";
          delete.text = "_";
          topdelete.text = "‾";
          changedelete.text = "~";
        };
      };
    };

    neogit = {
      enable = true;
    };

    diffview = {
      enable = true;
    };

    which-key.settings.spec = [
      {
        __unkeyed-1 = "<leader>gg";
        __unkeyed-2 = "<cmd>Neogit<CR>";
        desc = "Open Neogit";
      }
      {
        __unkeyed-1 = "<leader>gd";
        __unkeyed-2 = "<cmd>DiffviewOpen<CR>";
        desc = "Open Diff View";
      }
      {
        __unkeyed-1 = "<leader>gh";
        __unkeyed-2 = "<cmd>DiffviewFileHistory %<CR>";
        desc = "File History";
      }
      {
        __unkeyed-1 = "<leader>gq";
        __unkeyed-2 = "<cmd>DiffviewClose<CR>";
        desc = "Close Diff View";
      }
      {
        __unkeyed-1 = "]h";
        __unkeyed-2 = "<cmd>Gitsigns next_hunk<CR>";
        desc = "Next Git Hunk";
      }
      {
        __unkeyed-1 = "[h";
        __unkeyed-2 = "<cmd>Gitsigns prev_hunk<CR>";
        desc = "Previous Git Hunk";
      }
      {
        __unkeyed-1 = "<leader>hs";
        __unkeyed-2 = "<cmd>Gitsigns stage_hunk<CR>";
        desc = "Stage Hunk";
      }
      {
        __unkeyed-1 = "<leader>hr";
        __unkeyed-2 = "<cmd>Gitsigns reset_hunk<CR>";
        desc = "Reset Hunk";
      }
      {
        __unkeyed-1 = "<leader>hp";
        __unkeyed-2 = "<cmd>Gitsigns preview_hunk<CR>";
        desc = "Preview Hunk";
      }
      {
        __unkeyed-1 = "<leader>tb";
        __unkeyed-2 = "<cmd>Gitsigns toggle_current_line_blame<CR>";
        desc = "Toggle Line Blame";
      }
    ];
  };
}
