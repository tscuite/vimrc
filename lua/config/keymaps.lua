-- Keymaps are automatically loaded on the VeryLazy event.
-- Keep LazyVim's Space leader while preserving the previous backslash shortcuts.

local map = vim.keymap.set

local function legacy(mode, key, action, desc)
  map(mode, "<Bslash>" .. key, action, {
    silent = true,
    desc = "Legacy: " .. desc,
  })
end

-- Search and files.
legacy("n", "p", LazyVim.pick("files"), "Find Files")
legacy("n", "f", LazyVim.pick("grep"), "Search Text")
legacy("n", "b", function()
  Snacks.picker.buffers()
end, "Buffers")
legacy("n", "h", LazyVim.pick("oldfiles"), "Recent Files")
legacy("n", "e", function()
  Snacks.explorer({ cwd = LazyVim.root() })
end, "File Explorer")
legacy("n", "c", function()
  Snacks.picker.commands()
end, "Commands")

-- Save and quit.
legacy("n", "w", "<cmd>write<cr>", "Write")
legacy("n", "q", "<cmd>quit<cr>", "Quit")
legacy("n", "x", "<cmd>xit<cr>", "Write and Quit")

-- Code actions.
legacy({ "n", "x" }, "a", vim.lsp.buf.code_action, "Code Action")
legacy("n", "r", vim.lsp.buf.rename, "Rename")
legacy({ "n", "x" }, "=", function()
  LazyVim.format({ force = true })
end, "Format")
legacy("n", "l", "<cmd>Trouble diagnostics toggle<cr>", "Diagnostics")
legacy("n", "o", "<cmd>Trouble symbols toggle<cr>", "Document Symbols")

-- Preserve the old LSP switch. When nothing has been disabled yet, show LSP info.
local disabled_lsp = {}
legacy("n", "i", function()
  local clients = vim.lsp.get_clients()
  if #clients > 0 then
    for _, client in ipairs(clients) do
      disabled_lsp[client.name] = true
      pcall(vim.lsp.enable, client.name, false)
      client:stop()
    end
    vim.notify("LSP 已关闭")
  elseif next(disabled_lsp) then
    for name in pairs(disabled_lsp) do
      pcall(vim.lsp.enable, name, true)
    end
    disabled_lsp = {}
    vim.notify("LSP 已开启")
  else
    Snacks.picker.lsp_config()
  end
end, "Toggle LSP")

legacy("n", "m", function()
  vim.opt.mouse = vim.o.mouse == "" and "a" or ""
  vim.notify("鼠标已" .. (vim.o.mouse == "" and "关闭" or "开启"))
end, "Toggle Mouse")
