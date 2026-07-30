if vim.fn.has("nvim-0.11") ~= 1 then
  error("This configuration requires Neovim 0.11 or newer")
end

vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

if vim.g.native_lsp_auto_start == nil then
  -- Keep the old low-resource behaviour: press \i when IDE features are needed.
  vim.g.native_lsp_auto_start = false
end

require("config.options")
require("config.keymaps")
require("config.autocmds")

local native_lsp = require("config.lsp")
native_lsp.setup()

if vim.g.native_lsp_auto_start == true or vim.g.native_lsp_auto_start == 1 then
  native_lsp.start({ quiet = true })
end
