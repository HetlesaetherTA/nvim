local enabled = true
if not enabled then
  return {}
end

return {
  -- Install rust analyzer
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "rust_analyzer" })
      return opts
    end,
  },

  -- Treesitter parser is installed for highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "rust", "ron" })
      end
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

      -- rust-analyzer configuration
      lsp.register("rust_analyzer", "rust", {
        cmd = { "rust-analyzer" },
        root_dir = function(buf)
          return vim.fs.root(buf, { "Cargo.toml", "rust-project.json", ".git" })
        end,
        settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            check = { command = "clippy" },
            inlayHints = { locationLinks = false },
          },
        },
      })

      return opts
    end,
  },
}
