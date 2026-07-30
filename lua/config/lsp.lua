local M = {}

local stopped = {}
local setup_done = false

local function client_key(client)
  return table.concat({
    client.name,
    client.root_dir or "",
    vim.inspect(client.config.cmd),
  }, "\0")
end

local function remember(client)
  local key = client_key(client)
  if stopped[key] then
    return
  end

  local buffers = {}
  for bufnr in pairs(client.attached_buffers) do
    buffers[#buffers + 1] = bufnr
  end

  stopped[key] = {
    name = client.name,
    config = vim.deepcopy(client.config),
    buffers = buffers,
  }
end

local function stop_client(client)
  remember(client)
  if client.name ~= "jdtls" then
    pcall(vim.lsp.enable, client.name, false)
  end
  client:stop()
end

function M.stop()
  vim.g.ide_enabled = false
  for _, client in ipairs(vim.lsp.get_clients()) do
    stop_client(client)
  end
  vim.notify("LSP 已关闭")
end

local function restart_jdtls(entry)
  local attached = false
  for _, bufnr in ipairs(entry.buffers) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].filetype == "java" then
      vim.api.nvim_buf_call(bufnr, function()
        require("jdtls").start_or_attach(entry.config)
      end)
      attached = true
    end
  end

  if not attached and vim.bo.filetype == "java" then
    require("jdtls").start_or_attach(entry.config)
  end
end

function M.start()
  vim.g.ide_enabled = true

  local enabled = {}
  for _, entry in pairs(stopped) do
    if entry.name == "jdtls" then
      restart_jdtls(entry)
    elseif not enabled[entry.name] then
      pcall(vim.lsp.enable, entry.name, true)
      enabled[entry.name] = true
    end
  end

  stopped = {}
  vim.notify("LSP 已开启")
end

function M.toggle()
  if vim.g.ide_enabled == false then
    M.start()
  else
    M.stop()
  end
end

function M.setup()
  if setup_done then
    return
  end
  setup_done = true
  vim.g.ide_enabled = vim.g.ide_enabled ~= false

  local group = vim.api.nvim_create_augroup("tscuite_lsp_toggle", { clear = true })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(args)
      if vim.g.ide_enabled == false then
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client then
          vim.schedule(function()
            stop_client(client)
          end)
        end
      end
    end,
  })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      for _, client in ipairs(vim.lsp.get_clients({ name = "jdtls" })) do
        client:stop(true)
      end
    end,
    desc = "Stop jdtls before Neovim exits",
  })

  vim.api.nvim_create_user_command("LspToggle", M.toggle, { desc = "Toggle all LSP clients" })
end

return M
