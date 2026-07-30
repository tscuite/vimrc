local core = vim.api.nvim_create_augroup("tscuite_core", { clear = true })

vim.api.nvim_create_autocmd("BufReadPost", {
  group = core,
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 1 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = core,
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd("silent! checktime")
    end
  end,
})

local filetypes = vim.api.nvim_create_augroup("tscuite_filetypes", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = filetypes,
  pattern = "go",
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 0
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = filetypes,
  pattern = "python",
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.colorcolumn = "88"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = filetypes,
  pattern = { "java", "rust", "dockerfile" },
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = filetypes,
  pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = filetypes,
  pattern = "markdown",
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})

vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = false,
  underline = true,
  signs = true,
  virtual_text = { spacing = 2, prefix = "●" },
  float = { border = "rounded", source = true },
})

local lsp_attach = vim.api.nvim_create_augroup("tscuite_native_lsp_attach", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_attach,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end

    if client:supports_method("textDocument/documentHighlight") and not vim.b[args.buf].native_lsp_highlight then
      vim.b[args.buf].native_lsp_highlight = true
      local highlight = vim.api.nvim_create_augroup("tscuite_lsp_highlight_" .. args.buf, { clear = true })
      vim.api.nvim_create_autocmd("CursorHold", {
        group = highlight,
        buffer = args.buf,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "BufLeave" }, {
        group = highlight,
        buffer = args.buf,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})
