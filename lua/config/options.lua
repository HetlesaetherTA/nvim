-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.mapleader = " "

vim.cursorline = true
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.incsearch = true
vim.opt.smarttab = true
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.autochdir = true

vim.opt.wrap = false
vim.opt.mouse = "a"
vim.opt.cmdheight = 2

vim.opt.incsearch = true
vim.opt.hlsearch = false

vim.g.go_asmfmt_autosave = 0

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
})

vim.opt.showmatch = true -- brief flash of matching paren (built-in)
vim.opt.cursorline = true -- highlight current line (you already enable this)
vim.opt.termguicolors = true

vim.g.matchup_matchparen_offscreen = { method = "popup" }
vim.g.matchup_matchparen_deferred = 1
vim.g.matchup_surround_enabled = 1

vim.opt.switchbuf = "useopen,usetab"
