# Claude Code integration via toggleterm
# Uses the Claude Code CLI already installed by claude.nix module
# (avoids NixVim's claude-code plugin which bundles an unfree CLI package)
{ pkgs, ... }:
{
  extraConfigLua = ''
    -- Lazy-initialized Claude terminal instances (created on first use)
    -- High count numbers (50-52) to never conflict with regular terminals (1-3)
    local _claude = {}

    local function get_claude_term(key, cmd, count)
      if not _claude[key] then
        local Terminal = require("toggleterm.terminal").Terminal
        _claude[key] = Terminal:new({
          cmd = cmd,
          direction = "vertical",
          size = function() return math.floor(vim.o.columns * 0.5) end,
          hidden = true,
          count = count,
          on_open = function(term)
            vim.cmd("startinsert!")
          end,
        })
      end
      return _claude[key]
    end

    vim.api.nvim_create_user_command("ClaudeCode", function()
      get_claude_term("main", "claude", 50):toggle()
    end, { desc = "Toggle Claude Code in a vertical split" })

    vim.api.nvim_create_user_command("ClaudeCodeContinue", function()
      get_claude_term("continue", "claude --continue", 51):toggle()
    end, { desc = "Continue Claude Code conversation" })

    vim.api.nvim_create_user_command("ClaudeCodeResume", function()
      get_claude_term("resume", "claude --resume", 52):toggle()
    end, { desc = "Resume Claude Code conversation" })
  '';

  keymaps = [
    # Terminal-mode: Ctrl+; to toggle Claude Code from inside any terminal
    {
      mode = "t";
      key = "<C-;>";
      action = "<C-\\><C-n><cmd>ClaudeCode<CR>";
      options.desc = "Toggle Claude Code";
    }
  ];

  plugins = {
    which-key.settings.spec = [
      {
        __unkeyed-1 = "<leader>cc";
        __unkeyed-2 = "<cmd>ClaudeCode<CR>";
        desc = "Toggle Claude Code";
      }
      {
        __unkeyed-1 = "<leader>cC";
        __unkeyed-2 = "<cmd>ClaudeCodeContinue<CR>";
        desc = "Continue Conversation";
      }
      {
        __unkeyed-1 = "<leader>cr";
        __unkeyed-2 = "<cmd>ClaudeCodeResume<CR>";
        desc = "Resume Conversation";
      }
    ];
  };
}
