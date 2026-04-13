{ lib, ... }:
{
  autoCmd = [
    # Biome conflict resolution: when Biome LSP is active, disable formatting
    # in typescript-tools and jsonls to avoid conflicts (pattern from r17x/universe)
    {
      event = [ "LspAttach" ];
      callback.__raw = ''
        function()
          local bufnr = vim.api.nvim_get_current_buf()
          local clients = vim.lsp.get_clients()
          local is_biome_active = function()
            for _, client in ipairs(clients) do
              if client.name == "biome" and client.attached_buffers[bufnr] then
                return true
              end
            end
            return false
          end

          for _, client in ipairs(clients) do
            if is_biome_active() then
              if client.name == "typescript-tools" or client.name == "jsonls" then
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.documentRangeFormattingProvider = false
              end
            end
          end
        end
      '';
    }
  ];

  plugins = {
    lsp = {
      enable = true;
      servers = {
        ts_ls.enable = false;

        biome = {
          enable = true;
          autostart = true;
        };

        pyright = {
          enable = true;
          autostart = true;
        };

        nixd = {
          enable = true;
          autostart = true;
          settings = {
            formatting.command = [ "nixfmt" ];
            diagnostic.suppress = [ "sema-escaping-with" ];
          };
        };

        jsonls = {
          enable = true;
          autostart = true;
          extraOptions.settings.json = {
            validate.enable = true;
            schemas = [
              {
                description = "TypeScript compiler configuration file";
                fileMatch = [ "tsconfig.json" "tsconfig.*.json" ];
                url = "https://json.schemastore.org/tsconfig.json";
              }
              {
                description = "Package JSON";
                fileMatch = [ "package.json" ];
                url = "https://json.schemastore.org/package.json";
              }
            ];
          };
        };

        yamlls = {
          enable = true;
          autostart = true;
        };

        bashls = {
          enable = true;
          autostart = true;
        };

        dockerls = {
          enable = true;
          autostart = true;
        };

        lua_ls = {
          enable = true;
          autostart = true;
        };
      };
    };

    typescript-tools = {
      enable = true;
      settings = {
        code_lens = "references_only";
        complete_function_calls = true;
        expose_as_code_action = "all";
      };
    };

    conform-nvim = {
      enable = true;
      settings = {
        format_on_save = {
          timeout_ms = 500;
          lsp_format = "fallback";
        };
        formatters_by_ft = {
          javascript = [ "biome" ];
          javascriptreact = [ "biome" ];
          typescript = [ "biome" ];
          typescriptreact = [ "biome" ];
          json = [ "biome" ];
          jsonc = [ "biome" ];
          python = [ "ruff_format" ];
          nix = [ "nixfmt" ];
          lua = [ "stylua" ];
        };
      };
    };

    lspsaga = {
      enable = true;
      settings = {
        lightbulb.sign = false;
        lightbulb.virtualText = true;
        lightbulb.debounce = 40;
      };
    };

    trouble = {
      enable = true;
    };

    lsp-format.enable = true;

    which-key.settings.spec = [
      {
        __unkeyed-1 = "K";
        __unkeyed-2 = "<cmd>Lspsaga hover_doc<CR>";
        desc = "Hover Documentation";
      }
      {
        __unkeyed-1 = "gd";
        __unkeyed-2 = "<cmd>Lspsaga peek_definition<CR>";
        desc = "Peek Definition";
      }
      {
        __unkeyed-1 = "gD";
        __unkeyed-2 = "<cmd>Lspsaga goto_definition<CR>";
        desc = "Go to Definition";
      }
      {
        __unkeyed-1 = "ga";
        __unkeyed-2 = "<cmd>Lspsaga code_action<CR>";
        desc = "Code Action";
      }
      {
        __unkeyed-1 = "gr";
        __unkeyed-2 = "<cmd>Lspsaga rename<CR>";
        desc = "Rename Symbol";
      }
      {
        __unkeyed-1 = "gt";
        __unkeyed-2 = "<cmd>Lspsaga outline<CR>";
        desc = "Code Outline";
      }
      {
        __unkeyed-1 = "gf";
        __unkeyed-2 = "<cmd>Lspsaga finder<CR>";
        desc = "Find References";
      }
      {
        __unkeyed-1 = "[e";
        __unkeyed-2 = "<cmd>Lspsaga diagnostic_jump_prev<CR>";
        desc = "Previous Diagnostic";
      }
      {
        __unkeyed-1 = "]e";
        __unkeyed-2 = "<cmd>Lspsaga diagnostic_jump_next<CR>";
        desc = "Next Diagnostic";
      }
      {
        __unkeyed-1 = "ge";
        __unkeyed-2 = "<cmd>Trouble diagnostics toggle<CR>";
        desc = "Toggle Diagnostics";
      }
      {
        __unkeyed-1 = "<leader>li";
        __unkeyed-2 = "<cmd>LspInfo<CR>";
        desc = "LSP Info";
      }
      {
        __unkeyed-1 = "<leader>lf";
        __unkeyed-2 = "<cmd>Format<CR>";
        desc = "Format Buffer";
      }
      {
        __unkeyed-1 = "<leader>lr";
        __unkeyed-2 = "<cmd>Lspsaga rename<CR>";
        desc = "Rename";
      }
      {
        __unkeyed-1 = "<leader>la";
        __unkeyed-2 = "<cmd>Lspsaga code_action<CR>";
        desc = "Code Action";
      }
    ];
  };
}
