-- Beware: You may have to install pg_format manually
local enabled = true
if not enabled then
  return {}
end

return {
  -- postgres interface
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      if not vim.tbl_contains(opts.ensure_installed, "sqls") then
        table.insert(opts.ensure_installed, "sqls")
      end
      return opts
    end,
  },

  -- linter
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      if not vim.tbl_contains(opts.ensure_installed, "sqlfluff") then
        table.insert(opts.ensure_installed, "sqlfluff")
      end
      return opts
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "sql" })
      end
      return opts
    end,
  },

  -- Autoformatter
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        sql = { "pg_format" },
        pgsql = { "pg_format" },
      },
      formatters = {
        pg_format = {
          args = {
            "--spaces",
            "2",
            "--keyword-case",
            "2",
            "--wrap-limit",
            "120",
            "--wrap-after",
            "1",
            "-w",
            "0",
            "-C",
            "--no-space-function",
          },
        },
      },
    },
  },

  -- lsp config
  {
    "nanotee/sqls.nvim",
    lazy = true,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = { "nanotee/sqls.nvim" },
    opts = function(_, opts)
      local ok, lsp = pcall(require, "lang_support.lsp_util")
      if not ok then
        return opts
      end

      local sql_root = lsp.root_pattern({ ".git", "go.mod", "sqlc.yaml", "migrations/*.sql", "queries/*.sql" })

      lsp.register("sqls", "sql", {
        cmd = { "sqls" },
        filetypes = { "sql", "go" },
        root_dir = sql_root,
        on_attach = function(client, bufnr)
          local companion_ok, sqls_companion = pcall(require, "sqls")
          if companion_ok then
            sqls_companion.on_attach(client, bufnr)
          end
        end,
        settings = {
          sqls = {
            connections = {
              -- You can add more connection by copying line below
              {
                driver = "postgresql",
                dataSourceName = "host=127.0.0.1 port=5432 user=auth_app_user password=thisisatemporarypassword dbname=main sslmode=disable",
              },
            },
          },
        },
      })

      return opts
    end,
  },

  -- postges UI (view schemas and run queries)
  {
    "tpope/vim-dadbod",
    lazy = true,
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod" },
    keys = {
      { "<leader>db", "<cmd>DBUIToggle<cr>", desc = "Toggle Database Sidebar" },
    },
    init = function()
      vim.g.db_ui_save_location = vim.fn.stdpath("config") .. "/db_ui"
      vim.g.db_ui_show_database_value = 1

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          pcall(function()
            require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
          end)
        end,
      })
    end,
  },

  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        sql = { "sqlfluff" },
      },
    },
    config = function(_, opts)
      local lint = require("lint")
      lint.linters_by_ft = opts.linters_by_ft

      local sqlfluff = lint.linters.sqlfluff
      sqlfluff.args = {
        "lint",
        "--format=json",
        "--dialect=postgres",
        "--ignore=linting",
      }

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        pattern = "*.sql",
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
