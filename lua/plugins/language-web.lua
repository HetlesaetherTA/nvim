local enabled = true
if not enabled then
  return {}
end

return {
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}

      local servers = {
        "html",
        "cssls",
        "vtsls",
        "svelte",
        "jsonls",
        "eslint",
      }

      for _, server in ipairs(servers) do
        if not vim.tbl_contains(opts.ensure_installed, server) then
          table.insert(opts.ensure_installed, server)
        end
      end

      return opts
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "html",
          "css",
          "javascript",
          "typescript",
          "svelte",
        })
      end
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local lspconfig = require("lspconfig")
      local util = require("lspconfig.util")

      local root_pattern =
        util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", "svelte.config.js", ".git")

      lspconfig.html.setup({
        root_dir = root_pattern,
        settings = {
          html = {
            format = {
              enable = true,

              wrapLineLength = 120,
            },
            suggest = {
              html5 = true,
            },
          },
        },
      })

      lspconfig.cssls.setup({
        root_dir = root_pattern,
        settings = {
          css = {
            validate = true,
            format = { enable = true },
          },
          scss = {
            validate = true,
            format = { enable = true },
          },
        },
      })

      lspconfig.vtsls.setup({
        root_dir = root_pattern,
        settings = {
          typescript = {
            inlayHints = {
              parameterNames = {
                enabled = "all",
              },
            },
            preferences = {
              quoteStyle = "single",
            },
          },
          javascript = {
            inlayHints = {
              parameterNames = {
                enabled = "all",
              },
            },
            preferences = {
              quoteStyle = "single",
            },
          },
        },
      })

      lspconfig.svelte.setup({
        root_dir = root_pattern,
        settings = {
          svelte = {
            plugin = {
              svelte = { enable = true },
              css = { enable = true },
              html = { enable = true },
              typescript = { enable = true },
            },
          },
        },
      })

      lspconfig.jsonls.setup({
        root_dir = root_pattern,
        settings = {
          json = {
            validate = {
              enable = true,
            },
          },
        },
      })

      lspconfig.eslint.setup({
        root_dir = root_pattern,
        settings = {
          codeActionOnSave = {
            enable = true,
            mode = "all",
          },
        },
      })

      return opts
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}

      opts.formatters_by_ft.javascript = { "prettier" }
      opts.formatters_by_ft.javascriptreact = { "prettier" }
      opts.formatters_by_ft.typescript = { "prettier" }
      opts.formatters_by_ft.typescriptreact = { "prettier" }
      opts.formatters_by_ft.svelte = { "prettier" }
      opts.formatters_by_ft.css = { "prettier" }
      opts.formatters_by_ft.html = { "prettier" }
      opts.formatters_by_ft.json = { "prettier" }
      opts.formatters_by_ft.jsonc = { "prettier" }

      return opts
    end,
  },
}
