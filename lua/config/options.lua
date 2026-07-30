-- Options are automatically loaded before lazy.nvim startup.
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here.

-- Reserve backslash for the previous global shortcuts.
vim.g.maplocalleader = ","

-- Keep terminal selection behavior unless mouse support is explicitly enabled.
vim.opt.mouse = ""

-- Keep the gutter clean until line numbers are explicitly enabled.
vim.opt.number = false
vim.opt.relativenumber = false

-- Prefer the rustup-managed toolchain over a conflicting Homebrew rust formula.
local rustup_bin = "/opt/homebrew/opt/rustup/bin"
if vim.fn.isdirectory(rustup_bin) == 1 and not vim.env.PATH:find(rustup_bin, 1, true) then
  vim.env.PATH = rustup_bin .. ":" .. vim.env.PATH
end

-- Start without language servers. Press \i to enable them for the current session.
vim.g.ide_enabled = false
require("config.lsp").setup()
