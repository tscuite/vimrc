return {
  {
    "mrcjkb/rustaceanvim",
    opts = function(_, opts)
      opts.server = opts.server or {}
      opts.server.auto_attach = function(bufnr)
        if vim.bo[bufnr].buftype ~= "" or vim.bo[bufnr].filetype ~= "rust" then
          return false
        end
        if vim.fn.executable("rust-analyzer") == 0 then
          return false
        end

        if vim.g.ide_enabled == false then
          require("config.lsp").defer_start("rust-analyzer", tostring(bufnr), function()
            if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].filetype == "rust" then
              require("rustaceanvim.lsp").start(bufnr)
            end
          end)
          return false
        end

        return true
      end
    end,
  },
}
