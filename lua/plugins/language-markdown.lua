local enabled = true
if not enabled then
  return {}
end

local vault_path = os.getenv("OBSIDIAN") or "~/Obsidian"

return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      if not vim.tbl_contains(opts.ensure_installed, "mdformat") then
        table.insert(opts.ensure_installed, "mdformat")
      end
      return opts
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      local parsers = { "markdown", "markdown_inline", "latex" }
      for _, p in ipairs(parsers) do
        if not vim.tbl_contains(opts.ensure_installed, p) then
          table.insert(opts.ensure_installed, p)
        end
      end
      return opts
    end,
  },

  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      tables = {
        enable = true,
        use_virt_lines = true,
      },
      headings = {
        enable = true,
        shift_width = 1,
      },
      latex = {
        enable = true,
        hl = "@markup.math",
      },
    },
  },

  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    opts = {
      workspaces = {
        {
          name = "Obsidian",
          path = vault_path,
        },
      },
      picker = {
        name = "telescope",
      },
      ui = { enable = false },
    },
    keys = {
      {
        "<leader>osf",
        function()
          require("telescope.builtin").find_files({ cwd = vault_path, prompt_title = "Vault Files" })
        end,
        desc = "Search Vault from File",
      },
      {
        "<leader>osg",
        function()
          require("telescope.builtin").live_grep({ cwd = vault_path, prompt_title = "Grep Vault" })
        end,
        desc = "Grep Vault",
      },
    },
  },

  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.markdown = { "mdformat" }

      opts.formatters = opts.formatters or {}
      opts.formatters.mdformat = {
        args = { "--number", "--wrap", "80" },
      }
      return opts
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          vim.opt_local.wrap = true
          vim.opt_local.linebreak = true
          vim.opt_local.conceallevel = 2

          vim.opt_local.tabstop = 2
          vim.opt_local.shiftwidth = 2
          vim.opt_local.expandtab = true

          local ok, builtin = pcall(require, "telescope.builtin")
          if ok then
            vim.keymap.set("n", "<leader>sn", function()
              builtin.find_files({ cwd = vault_path, prompt_title = "Obsidian Vault" })
            end, { buffer = true, desc = "Search Obsidian Files" })

            vim.keymap.set("n", "<leader>sg", function()
              builtin.live_grep({ cwd = vault_path, prompt_title = "Grep Obsidian" })
            end, { buffer = true, desc = "Grep Obsidian Text" })
          end
        end,
      })
      return opts
    end,
  },
}
