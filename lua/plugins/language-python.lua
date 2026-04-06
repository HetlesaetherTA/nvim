local enabled = true
if not enabled then
  return {}
end

return {
  -- Install python LSP
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

  -- Install treesitter for syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "python" })
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

      -- Helper for python root detection
      local function get_py_root(buf)
        return vim.fs.root(buf, { "pyproject.toml", "setup.cfg", "setup.py", ".git" })
          or vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":p:h")
      end

      -- Pyright (types + completion)
      lsp.register("pyright", "python", {
        cmd = { "pyright-langserver", "--stdio" },
        root_dir = get_py_root,
      })

      -- Ruff (diagnostics/code actions)
      lsp.register("ruff", "python", {
        cmd = { "ruff", "server" },
        root_dir = get_py_root,
      })

      -- Jedi (completion/hover)
      lsp.register("jedi_language_server", "python", {
        cmd = { "jedi-language-server" },
        root_dir = get_py_root,
        initializationOptions = {
          diagnostics = { enable = false },
          hover = { enable = true },
          completion = { disableSnippets = false },
          markupKindPreferred = "markdown",
        },
      })

      return opts
    end,
  },
}
