local map = vim.keymap.set

local function edit_selected(items, prompt)
  vim.ui.select(items, { prompt = prompt }, function(choice)
    if choice then
      vim.cmd.edit(vim.fn.fnameescape(choice))
    end
  end)
end

-- Search and files, implemented only with Neovim APIs and ripgrep.
map("n", "<leader>p", function()
  vim.system({ "rg", "--files", "--hidden", "--glob", "!.git" }, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 and (result.stdout or "") == "" then
        vim.notify("没有找到文件", vim.log.levels.INFO)
        return
      end
      edit_selected(vim.split(vim.trim(result.stdout or ""), "\n", { trimempty = true }), "Files")
    end)
  end)
end, { silent = true, desc = "Find files" })

map("n", "<leader>f", function()
  vim.ui.input({ prompt = "Rg> " }, function(query)
    if not query or query == "" then
      return
    end
    vim.cmd("silent grep! " .. vim.fn.shellescape(query))
    vim.cmd("copen")
  end)
end, { silent = true, desc = "Search text" })

map("n", "<leader>b", function()
  local buffers = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      local name = vim.api.nvim_buf_get_name(bufnr)
      if name ~= "" then
        table.insert(buffers, name)
      end
    end
  end
  edit_selected(buffers, "Buffers")
end, { silent = true, desc = "Buffers" })

map("n", "<leader>h", function()
  local files = {}
  for _, path in ipairs(vim.v.oldfiles) do
    if vim.fn.filereadable(path) == 1 then
      table.insert(files, path)
    end
  end
  edit_selected(files, "Recent files")
end, { silent = true, desc = "Recent files" })

map("n", "<leader>e", "<cmd>Explore<cr>", { silent = true, desc = "Built-in file browser" })
map("n", "<leader>c", function()
  vim.ui.select(vim.fn.getcompletion("", "command"), { prompt = "Commands" }, function(choice)
    if choice then
      vim.api.nvim_feedkeys(":" .. choice .. " ", "n", false)
    end
  end)
end, { silent = true, desc = "Commands" })

-- Save, quit and buffers.
map("n", "<leader>w", "<cmd>write<cr>", { silent = true, desc = "Write" })
map("n", "<leader>q", "<cmd>quit<cr>", { silent = true, desc = "Quit" })
map("n", "<leader>x", "<cmd>xit<cr>", { silent = true, desc = "Write and quit" })
map("n", "[b", "<cmd>bprevious<cr>", { silent = true, desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<cr>", { silent = true, desc = "Next buffer" })

local function has_client(method)
  if not vim.g.ide_enabled then
    return false
  end
  return #vim.lsp.get_clients({ bufnr = 0, method = method }) > 0
end

local function lsp_action(method, action, fallback)
  return function()
    if has_client(method) then
      action()
    elseif fallback then
      fallback()
    else
      vim.notify("当前缓冲区没有支持此功能的 LSP；按 \\i 开启 IDE", vim.log.levels.INFO)
    end
  end
end

local function goto_definition()
  if has_client("textDocument/definition") then
    vim.lsp.buf.definition()
  elseif has_client("textDocument/declaration") then
    -- JDTLS advertises declarationProvider instead of definitionProvider.
    vim.lsp.buf.declaration()
  else
    vim.notify("LSP 尚未就绪，暂时使用 Vim 的当前文件跳转", vim.log.levels.INFO)
    vim.cmd("normal! gd")
  end
end

-- Keep the old IDE keys, now backed only by Neovim's built-in LSP client.
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
map("n", "[g", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { silent = true, desc = "Previous diagnostic" })
map("n", "]g", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { silent = true, desc = "Next diagnostic" })
map({ "n", "x" }, "<leader>a", lsp_action("textDocument/codeAction", vim.lsp.buf.code_action), {
  silent = true,
  desc = "Code action",
})
map("n", "<leader>r", lsp_action("textDocument/rename", vim.lsp.buf.rename), {
  silent = true,
  desc = "Rename",
})
map({ "n", "x" }, "<leader>=", lsp_action("textDocument/formatting", function()
  vim.lsp.buf.format({ async = true })
end), { silent = true, desc = "Format" })
map("n", "<leader>l", function()
  vim.diagnostic.setloclist({ open = true })
end, { silent = true, desc = "Diagnostics" })
map("n", "<leader>o", lsp_action("textDocument/documentSymbol", vim.lsp.buf.document_symbol), {
  silent = true,
  desc = "Document symbols",
})

-- Feature switches.
map("n", "<leader>i", function()
  require("config.lsp").toggle()
end, { silent = true, desc = "Toggle native LSP" })
map("n", "<leader>m", function()
  vim.opt.mouse = vim.o.mouse == "" and "a" or ""
  vim.notify("鼠标已" .. (vim.o.mouse == "" and "关闭" or "开启"))
end, { silent = true, desc = "Toggle mouse" })

-- Built-in completion.  <Tab> starts completion after a word, then cycles.
local function check_backspace()
  local column = vim.fn.col(".") - 1
  return column == 0 or vim.fn.getline("."):sub(column, column):match("%s") ~= nil
end

map("i", "<Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-n>"
  end
  if not has_client("textDocument/completion") or check_backspace() then
    return "<Tab>"
  end
  vim.schedule(vim.lsp.completion.get)
  return ""
end, { expr = true, silent = true, desc = "Complete or tab" })

map("i", "<S-Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-p>" or "<C-d>"
end, { expr = true, silent = true, desc = "Previous completion" })

map("i", "<CR>", function()
  if vim.fn.pumvisible() == 1 then
    local info = vim.fn.complete_info({ "selected" })
    return info.selected >= 0 and "<C-y>" or "<C-e><C-g>u<CR>"
  end
  return "<C-g>u<CR>"
end, { expr = true, silent = true, desc = "Confirm completion or newline" })

local function manual_completion(fallback)
  return function()
    if has_client("textDocument/completion") then
      vim.schedule(vim.lsp.completion.get)
      return ""
    end
    return fallback
  end
end

map("i", "<C-K>", manual_completion("<C-K>"), {
  expr = true,
  silent = true,
  desc = "Trigger native completion",
})
map("i", "<C-Space>", manual_completion("<C-Space>"), {
  expr = true,
  silent = true,
  desc = "Trigger native completion",
})
