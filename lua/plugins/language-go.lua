local enabled = true
if not enabled then
  return {}
end

return {
  -- Install go with mason
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      if not vim.tbl_contains(opts.ensure_installed, "gopls") then
        table.insert(opts.ensure_installed, "gopls")
      end
      return opts
    end,
  },

  -- install treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "go",
          "gomod",
          "gowork",
          "gosum",
          "gotmpl",
        })
      end
      return opts
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local ok, lsp = pcall(require, "lang_support.lsp_util")
      if not ok then
        return opts
      end

      local root_pattern = lsp.root_pattern({ "go.work", "go.mod", ".git" })

      lsp.register("gopls", "go", {
        cmd = { "gopls" },
        root_dir = root_pattern,

        on_new_config = function(new_config, new_root_dir)
          if vim.fn.filereadable(new_root_dir .. "/.tinygo") == 1 then
            new_config.settings.gopls.buildFlags = { "-tags=tinygo" }
          end
        end,

        settings = {
          gopls = {
            staticcheck = true,
            gofumpt = true,
            completeUnimported = true,
            usePlaceholders = true,
            experimentalPostfixCompletions = true,
            analyses = {
              unusedparams = true,
              nilness = true,
              unusedwrite = false,
            },
            directoryFilters = { "-**/vendor", "-**/node_modules" },
            hoverKind = "FullDocumentation",
            matcher = "Fuzzy",
          },
        },
      })

      return opts
    end,
  },
}
