local enabled = true
if not enabled then
  return {}
end

return {
  -- 1. Automate installing the Postgres LSP via Mason
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      if not vim.tbl_contains(opts.ensure_installed, "postgres_lsp") then
        table.insert(opts.ensure_installed, "postgres_lsp")
      end
      return opts
    end,
  },

  -- 2. SQL Treesitter parser configuration
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "sql" })
      end
      return opts
    end,
  },

  -- 3. SQL Linting & Injected Formatting (Go embedded strings + Standalone SQL)
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        sql = { "sleek" },
        ["_"] = { "injected" },
      },
    },
  },

  -- 4. LSP Server Setup using your custom lsp_util helper
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local ok, lsp = pcall(require, "lang_support.lsp_util")
      if not ok then
        return opts
      end

      -- Root fallback checking for SQL projects
      local root_pattern = lsp.root_pattern({ ".git", "migrations", "schema.sql" })

      lsp.register("postgres_lsp", "sql", {
        cmd = { "postgres-lsp" },
        root_dir = root_pattern,
        settings = {
          postgres_lsp = {
            connections = {
              {
                name = "development",
                url = "postgres://postgres:postgres@localhost:5432/postgres?sslmode=disable",
              },
            },
          },
        },
      })

      return opts
    end,
  },
}
