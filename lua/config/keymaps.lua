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

-- Keep the previous global LSP jumps. LazyVim's buffer-local mappings can
-- override these after attachment, but these remain available during startup.
local function has_client(method)
  return vim.g.ide_enabled ~= false and #vim.lsp.get_clients({ bufnr = 0, method = method }) > 0
end

local function lsp_action(method, action, fallback)
  return function()
    if has_client(method) then
      action()
    elseif fallback then
      fallback()
    else
      vim.notify("当前文件没有支持此功能的 LSP；按 \\i 开启 LSP", vim.log.levels.INFO)
    end
  end
end

local function goto_definition()
  if has_client("textDocument/definition") then
    vim.lsp.buf.definition()
  elseif has_client("textDocument/declaration") then
    vim.lsp.buf.declaration()
  else
    vim.notify("LSP 尚未就绪，暂时使用 Vim 的当前文件跳转", vim.log.levels.INFO)
    vim.cmd("normal! gd")
  end
end

map("n", "gd", goto_definition, { silent = true, desc = "Definition" })
map("n", "gD", lsp_action("textDocument/declaration", vim.lsp.buf.declaration), {
  silent = true,
  desc = "Declaration",
})
map("n", "gr", lsp_action("textDocument/references", vim.lsp.buf.references), {
  silent = true,
  nowait = true,
  desc = "References",
})
map("n", "gi", lsp_action("textDocument/implementation", vim.lsp.buf.implementation), {
  silent = true,
  desc = "Implementation",
})
map(
  "n",
  "K",
  lsp_action("textDocument/hover", vim.lsp.buf.hover, function()
    vim.cmd("normal! K")
  end),
  { silent = true, desc = "Hover" }
)

-- Code actions.
legacy({ "n", "x" }, "a", vim.lsp.buf.code_action, "Code Action")
legacy("n", "r", vim.lsp.buf.rename, "Rename")
legacy({ "n", "x" }, "=", function()
  LazyVim.format({ force = true })
end, "Format")
legacy("n", "l", "<cmd>Trouble diagnostics toggle<cr>", "Diagnostics")
legacy("n", "o", "<cmd>Trouble symbols toggle<cr>", "Document Symbols")

-- Keep the previous global IDE switch, including manually managed jdtls clients.
local lsp = require("config.lsp")
lsp.setup()
legacy("n", "i", lsp.toggle, "Toggle LSP")

legacy("n", "m", function()
  vim.opt.mouse = vim.o.mouse == "" and "a" or ""
  vim.notify("鼠标已" .. (vim.o.mouse == "" and "关闭" or "开启"))
end, "Toggle Mouse")
