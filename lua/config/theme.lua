local M = {}

M.default = "tokyonight-moon"

local function valid(name)
  return type(name) == "string" and name:match("^[%w_.-]+$") ~= nil
end

local function apply_transparency()
  require("config.transparency").apply()
end

function M.state_file()
  local override = vim.env.NVIM_COLORSCHEME_STATE
  if override and override ~= "" then
    return override
  end
  return vim.fn.stdpath("state") .. "/colorscheme"
end

function M.get()
  local ok, lines = pcall(vim.fn.readfile, M.state_file(), "", 1)
  local name = ok and lines[1] or nil
  return valid(name) and name or M.default
end

function M.save(name)
  if not valid(name) then
    return false, "无效的主题名称"
  end

  local path = M.state_file()
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  local ok, result = pcall(vim.fn.writefile, { name }, path)
  if not ok or result ~= 0 then
    return false, ok and "无法写入主题状态" or result
  end
  return true
end

function M.apply()
  local name = M.get()
  local ok, err = pcall(vim.cmd.colorscheme, name)
  if ok then
    apply_transparency()
    return
  end

  pcall(vim.cmd.colorscheme, M.default)
  apply_transparency()
  if name ~= M.default then
    M.save(M.default)
    vim.schedule(function()
      vim.notify(("主题 %s 加载失败，已恢复 %s：%s"):format(name, M.default, err), vim.log.levels.WARN)
    end)
  end
end

function M.pick()
  Snacks.picker.colorschemes({
    confirm = function(picker, item)
      picker:close()
      if not item then
        return
      end

      picker.preview.state.colorscheme = nil
      vim.schedule(function()
        local ok, err = pcall(vim.cmd.colorscheme, item.text)
        if not ok then
          vim.notify(("主题加载失败：%s"):format(err), vim.log.levels.ERROR)
          return
        end

        apply_transparency()
        local saved, save_err = M.save(item.text)
        if saved then
          vim.notify("主题已保存：" .. item.text)
        else
          vim.notify("主题保存失败：" .. save_err, vim.log.levels.ERROR)
        end
      end)
    end,
  })
end

return M
