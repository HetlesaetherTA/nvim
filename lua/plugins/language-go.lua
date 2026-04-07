local enabled = true
if not enabled then
  return {}
end

return {
  -- Install go with mason
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      if not vim.tbl_contains(opts.ensure_installed, "gopls") then
        table.insert(opts.ensure_installed, "gopls")
      end
      return opts
    end,
  },

  -- Go debugger
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "leoluz/nvim-dap-go",
    },
    config = function()
      local dap = require("dap")
      local ui = require("dapui")

      require("dap-go").setup()
      ui.setup()

      dap.listeners.before.attach.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        ui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        ui.close()
      end

      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue / Start" })
      vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step Into" })
      vim.keymap.set("n", "<leader>dn", dap.step_over, { desc = "Step Over" })
      vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Step Out" })
      vim.keymap.set("n", "<leader>dus", ui.toggle, { desc = "Toggle UI" })
      vim.keymap.set("n", "<leader>dt", function()
        require("dap-go").debug_test()
      end, { desc = "Debug Test" })
    end,
  },

  -- install treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "go",
          "gomod",
          "gowork",
          "gosum",
          "gotmpl",
        })
      end
      return opts
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local ok, lsp = pcall(require, "lang_support.lsp_util")
      if not ok then
        return opts
      end

      local root_pattern = lsp.root_pattern({ "go.work", "go.mod", ".git" })

      lsp.register("gopls", "go", {
        cmd = { "gopls" },
        root_dir = root_pattern,

        on_new_config = function(new_config, new_root_dir)
          if vim.fn.filereadable(new_root_dir .. "/.tinygo") == 1 then
            new_config.settings.gopls.buildFlags = { "-tags=tinygo" }
          end
        end,

        settings = {
          gopls = {
            staticcheck = true,
            gofumpt = true,
            completeUnimported = true,
            usePlaceholders = true,
            experimentalPostfixCompletions = true,
            analyses = {
              unusedparams = true,
              nilness = true,
              unusedwrite = false,
            },
            directoryFilters = { "-**/vendor", "-**/node_modules" },
            hoverKind = "FullDocumentation",
            matcher = "Fuzzy",
          },
        },
      })

      return opts
    end,
  },
}
