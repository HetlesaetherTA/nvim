local enabled = true
if not enabled then
  return {}
end

return {
  -- Install formatters, debuggers, and LSP servers via Mason
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "clang-format",
        "codelldb",
        "clangd", -- Added LSP server for C/C++
      })
      return opts
    end,
  },

  -- Configure LSP for C code suggestions
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--completion-style=detailed",
            "--header-insertion=iwyu",
          },
        },
      },
    },
  },

  -- Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "c",
          "cpp",
          "make",
          "cmake",
        })
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
      opts.formatters_by_ft.c = { "clang-format" }
      opts.formatters_by_ft.cpp = { "clang-format" }
      return opts
    end,
  },
}
