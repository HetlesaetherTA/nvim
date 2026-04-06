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
        "ts_ls",
        "svelte",
      })
      return opts
    end,
  },

  -- Configure lsp
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local ok, lsp = pcall(require, "lang_support.lsp_util")
      if not ok then
        return opts
      end

      local web_root = lsp.root_pattern({ "package.json", "tsconfig.json", "jsconfig.json", ".git" })

      -- HTML configuration
      lsp.register("html", "html", {
        cmd = { "vscode-html-language-server", "--stdio" },
        root_dir = web_root,
        settings = {
          html = {
            format = { enable = true, wrapLineLength = 120 },
            suggest = { html5 = true },
          },
        },
      })

      -- CSS / SCSS / LESS configuration
      lsp.register("cssls", { "css", "scss", "less" }, {
        cmd = { "vscode-css-language-server", "--stdio" },
        root_dir = web_root,
        settings = {
          css = { validate = true, format = { enable = true } },
          scss = { validate = true, format = { enable = true } },
        },
      })

      -- TypeScript / JavaScript configuration
      lsp.register("ts_ls", { "typescript", "javascript", "javascriptreact", "typescriptreact" }, {
        cmd = { "typescript-language-server", "--stdio" },
        root_dir = web_root,
        settings = {
          typescript = {
            inlayHints = { includeInlayParameterNameHints = "literals" },
            preferences = { quoteStyle = "single" },
          },
        },
      })

      -- Svelte configuration
      lsp.register("svelte", "svelte", {
        cmd = { "svelteserver", "--stdio" },
        root_dir = web_root,
      })

      return opts
    end,
  },
}
