-- Beware: You may have to install pg_format manually
local enabled = true
if not enabled then
  return {}
end

return {
  {
    "nanotee/sqls.nvim",
    lazy = true,
  },

  -- You need to define connections in ~/.config/sqls/config.yml
  config = function()
    local lspconfig = require("lspconfig")

    lspconfig.sqls.setup({
      cmd = { "sqls" },
      filetypes = { "sql", "go" },
      root_dir = lspconfig.util.root_pattern(".sqls.yml", "sqls.yml", ".git", "go.mod"),

      on_attach = function(client, bufnr)
        local status, sqls = pcall(require, "sqls")
        if status then
          sqls.on_attach(client, bufnr)
        else
          vim.notify("sqls.nvim not found, skipping setup", vim.log.levels.WARN)
        end
      end,
    })
  end,
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
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.sql = { "pg_format" }
      opts.formatters_by_ft.pgsql = { "pg_format" }

      opts.formatters = opts.formatters or {}
      opts.formatters.pg_format = {
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
      }
      return opts
    end,
  },

  -- postges UI (view schemas and run queries)
  {
    "tpope/vim-dadbod",
    lazy = false,
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod" },
    keys = {
      { "<leader>db", "<cmd>DBUIToggle<cr>", desc = "Toggle Database Sidebar" },
    },
    init = function()
      vim.g.db_ui_save_location = "/tmp"
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
