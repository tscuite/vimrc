local M = {}

local transparent_groups = {
  "Normal",
  "NormalNC",
  "NormalFloat",
  "NormalSB",
  "SignColumn",
  "SignColumnSB",
  "FoldColumn",
  "EndOfBuffer",
  "MsgArea",
  "FloatBorder",
  "FloatTitle",
  "WinBar",
  "WinBarNC",
  "LazyNormal",
  "MasonNormal",
  "WhichKeyNormal",
  "NeoTreeNormal",
  "NeoTreeNormalNC",
  "NeoTreeEndOfBuffer",
  "SnacksNormal",
  "SnacksNormalNC",
  "SnacksWinBar",
  "SnacksDashboardNormal",
  "SnacksPicker",
  "SnacksPickerBorder",
  "SnacksPickerInput",
  "SnacksPickerList",
  "SnacksPickerPreview",
  "TelescopeNormal",
  "TelescopeBorder",
  "TelescopePromptNormal",
  "TelescopePromptBorder",
  "TelescopeResultsNormal",
  "TelescopeResultsBorder",
  "TelescopePreviewNormal",
  "TelescopePreviewBorder",
}

function M.apply()
  for _, name in ipairs(transparent_groups) do
    if vim.fn.hlexists(name) == 1 then
      local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
      if ok then
        hl.bg = nil
        hl.ctermbg = nil
        vim.api.nvim_set_hl(0, name, hl)
      end
    end
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("tscuite_transparent_background", { clear = true })

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = M.apply,
    desc = "Keep every colorscheme transparent",
  })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "LazyLoad",
    callback = function()
      vim.schedule(M.apply)
    end,
    desc = "Keep lazy-loaded plugin windows transparent",
  })

  M.apply()
end

return M
