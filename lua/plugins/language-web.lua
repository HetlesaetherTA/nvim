-- Toggle this to false to disable Web support without deleting the file
local enabled = true
if not enabled then
  return {}
end

return {
  -- Install web resources with mason
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "html",
        "cssls",
        "vtsls",
        "svelte",
      })
      return opts
    end,
  },

  -- Configure lsp
  {
    "neovim/nvim-lspconfig",
    init = function()
      -- Inject servers directly into LazyVim's global option structure safely
      local lsp_opts =
        require("lazy.core.plugin").values(require("lazy.core.config").plugins["nvim-lspconfig"], "opts", false)
      lsp_opts.servers = lsp_opts.servers or {}

      -- HTML configuration
      lsp_opts.servers.html = {
        cmd = { "vscode-html-language-server", "--stdio" },
        root_dir = function(fname)
          return require("lspconfig.util").root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git")(fname)
        end,
        settings = {
          html = {
            format = { enable = true, wrapLineLength = 120 },
            suggest = { html5 = true },
          },
        },
      }

      -- CSS / SCSS / LESS configuration
      lsp_opts.servers.cssls = {
        cmd = { "vscode-css-language-server", "--stdio" },
        root_dir = function(fname)
          return require("lspconfig.util").root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git")(fname)
        end,
        settings = {
          css = { validate = true, format = { enable = true } },
          scss = { validate = true, format = { enable = true } },
        },
      }

      -- TypeScript / JavaScript configuration
      lsp_opts.servers.vtsls = {
        cmd = { "vtsls", "--stdio" },
        root_dir = function(fname)
          return require("lspconfig.util").root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git")(fname)
        end,
        settings = {
          typescript = {
            inlayHints = {
              parameterNames = { enabled = "all" },
            },
            preferences = { quoteStyle = "single" },
          },
        },
      }

      -- Svelte configuration
      lsp_opts.servers.svelte = {
        cmd = { "svelteserver", "--stdio" },
        root_dir = function(fname)
          return require("lspconfig.util").root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git")(fname)
        end,
      }
    end,
  },
}
