-- ~/.config/nvim/lua/plugins/tah.lua

-- This is just my personal config seperated from the lazyvim & omarchy defaults

return {
  -- SSH clipboard functionality
  {
    "ojroques/nvim-osc52",
    -- Only load OSC52 if we are in an SSH session (Linux or Mac)
    enabled = function()
      return vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil
    end,
    config = function()
      require("osc52").setup({})
      local function copy()
        if vim.v.event.operator == "y" and vim.v.event.regname == "+" then
          require("osc52").copy_register("+")
        end
      end
      vim.api.nvim_create_autocmd("TextYankPost", { callback = copy })
    end,
  },

  -- Logic for local Mac/Linux clipboard (Native)
  {
    "LazyVim/LazyVim",
    opts = function()
      local is_mac = vim.fn.has("mac") == 1
      local is_ssh = vim.env.SSH_TTY ~= nil

      -- If NOT in SSH, use the native system clipboard
      if not is_ssh then
        if is_mac then
          -- macOS specific clipboard provider
          vim.g.clipboard = {
            name = "macOS-clipboard",
            copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
            paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
            cache_enabled = 0,
          }
        end
        -- Sync with system clipboard
        vim.opt.clipboard = "unnamedplus"
      end
    end,
  },
  -- Extra colorscheme
  {
    "morhetz/gruvbox",
    lazy = false,
    priority = 1000,
    config = function() end,
  },

  -- Fun
  {
    "ThePrimeagen/vim-be-good",
    cmd = "VimBeGood",
  },

  -- sudo write
  {
    "lambdalisue/suda.vim",
    cmd = { "SudaWrite", "SudaRead" },
  },

  -- Tag overview
  {
    "preservim/tagbar",
    cmd = "TagbarToggle",
    keys = {
      { "<leader>tt", "<cmd>TagbarToggle<cr>", desc = "Toggle Tagbar" },
    },
  },

  -- Undotree
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = {
      { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Toggle Undotree" },
    },
  },

  -- Git porcelain
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git status (fugitive)" },
    },
  },

  -- Keep root dir static
  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup({
        manual_mode = false,

        detection_methods = { "lsp", "pattern" },
        patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "go.mod" },

        ignore_lsp = {},

        silent_chdir = true,

        datapath = vim.fn.stdpath("data"),
      })
    end,
  },

  -- Harpoon
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      local map = vim.keymap.set
      map("n", "<leader>a", function()
        harpoon:list():add()
      end, { desc = "Harpoon add file" })

      map("n", "<C-e>", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = "Harpoon quick menu" })
    end,
  },

  -- nnn file manager
  {
    "mcchrish/nnn.vim",
    cmd = { "NnnPicker", "NnnExplorer" },
    keys = {
      { "<leader>n", "<cmd>NnnPicker<cr>", desc = "nnn picker" },
    },
  },

  -- Colorizer
  {
    "NvChad/nvim-colorizer.lua",
    event = "VeryLazy",
    config = function()
      require("colorizer").setup()
    end,
  },

  -- Better % / matching
  {
    "andymass/vim-matchup",
    event = "VeryLazy",
  },

  -- Gopher
  {
    "olexsmir/gopher.nvim",
    ft = "go",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function(_, opts)
      require("gopher").setup(opts or {})
      local group = vim.api.nvim_create_augroup("GopherSetup", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "go",
        callback = function()
          vim.cmd("silent! GoInstallDeps")
        end,
      })
    end,
  },
}
