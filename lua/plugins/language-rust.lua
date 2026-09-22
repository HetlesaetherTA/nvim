local enabled = true
if not enabled then
  return {}
end

return {
  -- Install Rust LSP via Mason
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "rust_analyzer" })
      return opts
    end,
  },

  -- Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "rust", "ron" })
      end
      return opts
    end,
  },

  -- Configure LSP
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      opts.servers.rust_analyzer = {
        cmd = { "rust-analyzer" },
        root_dir = function(bufnr)
          return vim.fs.root(bufnr, { "Cargo.toml", "rust-project.json", ".git" })
        end,
        settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            check = { command = "clippy" },
            inlayHints = { locationLinks = false },
          },
        },
      }

      return opts
    end,
  },
}
