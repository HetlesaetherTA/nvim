local enabled = true
if not enabled then
  return {}
end

return {
  -- Install LSP
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

  -- Install treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "svelte", "css", "html", "javascript", "typescript" })
      end
    end,
  },

  -- LSP config
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local ok, lsp = pcall(require, "lang_support.lsp_util")
      if not ok then
        return opts
      end

      -- Root pattern for Svelte/Web projects
      local web_root = lsp.root_pattern({ "package.json", "svelte.config.js", "tsconfig.json", ".git" })

      -- Svelte Language Server registration
      lsp.register("svelte", "svelte", {
        cmd = { "svelteserver", "--stdio" },
        root_dir = web_root,
        settings = {
          svelte = {
            plugin = {
              -- Enable cross-language support inside .svelte files
              svelte = { enable = true },
              css = { enable = true },
              html = { enable = true },
              typescript = { enable = true },
            },
          },
        },
      })

      return opts
    end,
  },
}
