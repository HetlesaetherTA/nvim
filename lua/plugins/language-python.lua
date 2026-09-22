local enabled = true
if not enabled then
  return {}
end

return {
  -- Install Python LSPs via Mason
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "pyright",
        "ruff",
        "jedi_language_server",
      })
      return opts
    end,
  },

  -- Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "python" })
      end
      return opts
    end,
  },

  -- Configure LSP Servers directly in opts.servers
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      -- Root directory helper
      local function get_py_root(bufnr)
        return vim.fs.root(bufnr, { "pyproject.toml", "setup.cfg", "setup.py", ".git" })
          or vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":p:h")
      end

      -- Pyright (types + completion)
      opts.servers.pyright = {
        root_dir = get_py_root,
      }

      -- Ruff (diagnostics/code actions)
      opts.servers.ruff = {
        cmd = { "ruff", "server" },
        root_dir = get_py_root,
      }

      -- Jedi (completion/hover)
      opts.servers.jedi_language_server = {
        root_dir = get_py_root,
        init_options = {
          diagnostics = { enable = false },
          hover = { enable = true },
          completion = { disableSnippets = false },
          markupKindPreferred = "markdown",
        },
      }

      return opts
    end,
  },
}
