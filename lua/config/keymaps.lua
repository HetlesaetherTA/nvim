-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local nnoremap = require("config/helperKeymaps").nnoremap
-- local builtin = require("telescope.builtin")

-- file explorer (netrw)
-- Check if 'nnn' is installed
if vim.fn.executable("nnn") == 1 then
  vim.api.nvim_set_keymap("n", "<leader>pv", ":NnnPicker<CR>", { noremap = true, silent = true })
else
  vim.api.nvim_set_keymap("n", "<leader>pv", "<cmd>Ex<CR>", { noremap = true, silent = true })
end

-- disable space in visual
vim.api.nvim_set_keymap("v", "<Space>", "<Nop>", { noremap = true, silent = true })

vim.keymap.set("n", "<C-j>", "<C-d>zz", { desc = "Half page down and center" })
vim.keymap.set("n", "<C-k>", "<C-u>zz", { desc = "Half page up and center" })

-- swap current line with line {below: J, abolve: K}
vim.keymap.set("n", "J", ":m .+1<CR>==", { noremap = true, silent = true })
vim.keymap.set("n", "K", ":m .-2<CR>==", { noremap = true, silent = true })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

-- navigate back (n) and forward (n) in search array
vim.keymap.set("n", "n", "nzzzv")

-- Save to clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])

-- move 1 tab {left: <, right: >}
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "<", "<gv")

-- redo bound to shift+u
vim.keymap.set("n", "U", "<C-r>")

vim.keymap.set("n", "<leader>g", function()
  vim.diagnostic.open_float(nil, { focus = true, border = "rounded" })
end, { desc = "Line diagnostics" })

vim.keymap.set("n", "<leader>fa", function()
  -- Grab the active fold level setting for the current window
  local current_foldlevel = vim.wo.foldlevel

  -- If foldlevel is greater than 0, things are expanded. Collapse everything.
  if current_foldlevel > 0 then
    vim.cmd("normal! zM")
    vim.wo.foldlevel = 0
    print("󰁂 All folds collapsed")
  else
    -- If foldlevel is 0, everything is hidden. Expand everything back out.
    vim.cmd("normal! zR")
    vim.wo.foldlevel = 99
    print("󰁃 All folds expanded")
  end
end, { desc = "Toggle Fold All (Toggle zM/zR)" })

vim.keymap.set("n", "<C-f>", "zA", { desc = "Toggle code fold and propegate" })

-- Go to Definition in a VERTICAL split
vim.keymap.set("n", "gv", function()
  vim.cmd("vsplit")
  vim.lsp.buf.definition()
end, { desc = "LSP: Definition in Vertical Split" })

-- Go to Definition in a HORIZONTAL split
vim.keymap.set("n", "gs", function()
  vim.cmd("split")
  vim.lsp.buf.definition()
end, { desc = "LSP: Definition in Horizontal Split" })
