local function macos_java_home(version)
  if vim.fn.has("mac") ~= 1 or vim.fn.executable("/usr/libexec/java_home") ~= 1 then
    return nil
  end

  local home = vim.fn.trim(vim.fn.system({ "/usr/libexec/java_home", "-v", version }))
  return vim.v.shell_error == 0 and home ~= "" and home or nil
end

return {
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      local jdtls = require("jdtls")
      if not jdtls._tscuite_deferred_start then
        local start_or_attach = jdtls.start_or_attach

        jdtls.start_or_attach = function(config, ...)
          local bufnr = vim.api.nvim_get_current_buf()
          local key = ("%d:%s"):format(bufnr, config.root_dir or "")
          local args = { ... }
          local delayed_config = vim.deepcopy(config)

          if
            require("config.lsp").defer_start("jdtls", key, function()
              if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].filetype == "java" then
                vim.api.nvim_buf_call(bufnr, function()
                  start_or_attach(delayed_config, unpack(args))
                end)
              end
            end)
          then
            return
          end

          return start_or_attach(config, unpack(args))
        end
        jdtls._tscuite_deferred_start = true
      end

      local tooling_home = macos_java_home("21")
      local project_home = vim.env.JAVA_HOME

      if not project_home or vim.fn.executable(project_home .. "/bin/java") ~= 1 then
        project_home = macos_java_home("17")
      end

      if tooling_home then
        table.insert(opts.cmd, 2, "--java-executable=" .. tooling_home .. "/bin/java")
      end

      vim.list_extend(opts.cmd, {
        "--jvm-arg=-Xms128m",
        "--jvm-arg=-Xmx1g",
        "--jvm-arg=-XX:ActiveProcessorCount=2",
        "--jvm-arg=-Djava.awt.headless=true",
      })

      opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
        java = {
          import = {
            gradle = {
              java = { home = project_home },
              arguments = "--no-daemon --max-workers=1 --no-parallel",
              jvmArguments = "-Xms128m -Xmx1g -XX:MaxMetaspaceSize=384m -XX:ActiveProcessorCount=2"
                .. " -Dfile.encoding=UTF-8 -Djava.awt.headless=true",
              annotationProcessing = { enabled = true },
            },
          },
          jdt = {
            ls = {
              lombokSupport = { enabled = true },
            },
          },
          configuration = {
            runtimes = project_home and {
              { name = "JavaSE-17", path = project_home, default = true },
            } or nil,
          },
          maxConcurrentBuilds = 1,
        },
      })

      opts.jdtls = vim.tbl_deep_extend("force", opts.jdtls or {}, {
        cmd_env = project_home and { JAVA_HOME = project_home } or nil,
        init_options = {
          settings = vim.deepcopy(opts.settings),
        },
      })
    end,
  },
}
