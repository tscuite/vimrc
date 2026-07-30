-- Options are automatically loaded before lazy.nvim startup.
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here.

-- Reserve backslash for the previous global shortcuts.
vim.g.maplocalleader = ","

-- Keep terminal selection behavior unless mouse support is explicitly enabled.
vim.opt.mouse = ""

-- Show real line numbers on every line instead of relative distances.
vim.opt.number = true
vim.opt.relativenumber = false

-- Start without language servers. Press \i to enable them for the current session.
vim.g.ide_enabled = false
require("config.lsp").setup()
