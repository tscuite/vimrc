local M = {
  available_names = {},
  status = {},
}

-- Avoid one recursive filesystem watcher per project directory.  Buffers still
-- send normal didOpen/didChange/didSave events, while large repositories use
-- substantially fewer file descriptors and less background work.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false
vim.lsp.config("*", { capabilities = capabilities })

local user_dir = vim.fn.expand("~")
local coc_extensions = user_dir .. "/.config/coc/extensions"
local coc_modules = coc_extensions .. "/node_modules"
local node = vim.fn.exepath("node")

local function readable(path)
  return path and path ~= "" and vim.fn.filereadable(path) == 1
end

local function executable(path)
  return path and path ~= "" and vim.fn.executable(path) == 1
end

local function command_path(name)
  local path = vim.fn.exepath(name)
  return path ~= "" and path or nil
end

local function first_executable(...)
  for index = 1, select("#", ...) do
    local candidate = select(index, ...)
    if executable(candidate) then
      return candidate
    end
  end
end

local function first_readable(...)
  for index = 1, select("#", ...) do
    local candidate = select(index, ...)
    if readable(candidate) then
      return candidate
    end
  end
end

local function add(name, label, source, command, config, missing)
  local available = command ~= nil
  table.insert(M.status, {
    name = name,
    label = label,
    source = source,
    command = command,
    available = available,
    missing = missing,
  })
  if not available then
    return
  end
  vim.lsp.config(name, config)
  table.insert(M.available_names, name)
end

local lua_ls = command_path("lua-language-server")
add("lua_ls", "Lua", "PATH", lua_ls, {
  cmd = { lua_ls },
  filetypes = { "lua" },
  root_markers = {
    { ".luarc.json", ".luarc.jsonc", ".emmyrc.json" },
    { ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml" },
    { ".git" },
  },
  on_init = function(client)
    local workspace = client.workspace_folders and client.workspace_folders[1]
    local path = workspace and vim.uri_to_fname(workspace.uri)
    if path and path ~= vim.fn.stdpath("config") and (readable(path .. "/.luarc.json") or readable(path .. "/.luarc.jsonc")) then
      return
    end
    client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua or {}, {
      runtime = {
        version = "LuaJIT",
        path = { "lua/?.lua", "lua/?/init.lua" },
      },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
      telemetry = { enable = false },
    })
  end,
  settings = { Lua = {} },
}, "brew install lua-language-server")

local clangd = command_path("clangd")
add("clangd", "C / C++", "PATH", clangd, {
  cmd = { clangd, "--background-index", "--clang-tidy" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_markers = {
    { ".clangd", ".clang-tidy", ".clang-format" },
    { "compile_commands.json", "compile_flags.txt" },
    { ".git" },
  },
}, "install clangd")

local gopls_system = command_path("gopls")
local gopls_cached = coc_extensions .. "/coc-go-data/bin/gopls"
local gopls = first_executable(gopls_system, gopls_cached)
add("gopls", "Go", gopls_system and "PATH" or "existing CoC server cache", gopls, {
  cmd = { gopls },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.work", "go.mod", ".git" },
  settings = {
    gopls = {
      semanticTokens = false,
    },
  },
}, "brew install gopls")

local pyright_system = command_path("pyright-langserver")
local pyright_script = first_readable(
  coc_modules .. "/coc-pyright/node_modules/pyright/langserver.index.js",
  coc_modules .. "/coc-pyright/node_modules/pyright/dist/pyright-langserver.js"
)
local pyright_cmd
local pyright_source
if pyright_system then
  pyright_cmd = { pyright_system, "--stdio" }
  pyright_source = "PATH"
elseif node ~= "" and pyright_script then
  pyright_cmd = { node, pyright_script, "--stdio" }
  pyright_source = "existing CoC server cache"
end
add("pyright", "Python", pyright_source, pyright_cmd and pyright_cmd[1], {
  cmd = pyright_cmd,
  filetypes = { "python" },
  root_markers = {
    "pyrightconfig.json",
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    ".git",
  },
  settings = {
    pyright = { disableTaggedHints = true },
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly",
      },
    },
  },
}, "npm install -g pyright")

local ts_server = command_path("typescript-language-server")
local ts_filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" }
local vue_plugin_path = coc_modules .. "/@yaegassy/coc-volar/node_modules/@vue/language-server"
local vue_plugin_available = vim.fn.isdirectory(vue_plugin_path) == 1
local vue_tsdk = coc_modules .. "/@yaegassy/coc-volar/node_modules/typescript/lib"

local function ts_root(bufnr, on_dir)
  local lock_root = vim.fs.root(bufnr, { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock" })
  local deno_root = vim.fs.root(bufnr, { "deno.json", "deno.jsonc" })
  local deno_lock_root = vim.fs.root(bufnr, { "deno.lock" })
  if deno_lock_root and (not lock_root or #deno_lock_root > #lock_root) then
    return
  end
  if deno_root and (not lock_root or #deno_root >= #lock_root) then
    return
  end
  on_dir(lock_root or vim.fs.root(bufnr, { "package.json", "tsconfig.json", "jsconfig.json", ".git" }) or vim.fn.getcwd())
end

local ts_config
if ts_server then
  ts_config = {
    cmd = function(dispatchers, config)
      local cmd = ts_server
      if config.root_dir then
        local local_cmd = vim.fs.joinpath(config.root_dir, "node_modules", ".bin", "typescript-language-server")
        if executable(local_cmd) then
          cmd = local_cmd
        end
      end
      return vim.lsp.rpc.start({ cmd, "--stdio" }, dispatchers, {
        cwd = config.root_dir,
        env = config.cmd_env,
        detached = config.detached,
      })
    end,
    filetypes = ts_filetypes,
    root_dir = ts_root,
    init_options = {
      hostInfo = "neovim",
      plugins = vue_plugin_available and {
        {
          name = "@vue/typescript-plugin",
          location = vue_plugin_path,
          languages = { "vue" },
          configNamespace = "typescript",
        },
      } or {},
    },
  }
end
add(
  "ts_ls",
  "JavaScript / TypeScript",
  "PATH",
  ts_server,
  ts_config,
  "npm install -g typescript-language-server typescript"
)

local vue_system = command_path("vue-language-server")
local vue_script = first_readable(
  coc_modules .. "/@yaegassy/coc-volar/node_modules/@vue/language-server/bin/vue-language-server.js"
)
local vue_cmd
local vue_source
if vue_system then
  vue_cmd = { vue_system, "--stdio" }
  vue_source = "PATH"
elseif node ~= "" and vue_script then
  vue_cmd = { node, vue_script, "--stdio" }
  vue_source = "existing CoC server cache"
end
local vue_available = vue_cmd and ts_server and vue_plugin_available
add("vue_ls", "Vue", vue_source, vue_available and vue_cmd[1] or nil, {
  cmd = vue_cmd,
  filetypes = { "vue" },
  init_options = {
    typescript = {
      tsdk = vue_tsdk,
    },
    vue = {
      hybridMode = true,
    },
  },
  root_markers = {
    "package.json",
    "vue.config.js",
    "vite.config.js",
    "vite.config.ts",
    "nuxt.config.js",
    "nuxt.config.ts",
    ".git",
  },
  on_init = function(client)
    local retries = 0
    local function forward(_, result, context)
      local ts_client = vim.lsp.get_clients({ bufnr = context.bufnr, name = "ts_ls" })[1]
      if not ts_client then
        if retries < 10 then
          retries = retries + 1
          vim.defer_fn(function()
            forward(nil, result, context)
          end, 100)
        else
          vim.notify("vue_ls 找不到 ts_ls，Vue 的 TypeScript 功能不可用", vim.log.levels.ERROR)
        end
        return
      end

      local param = unpack(result)
      local id, command, payload = unpack(param)
      ts_client:exec_cmd({
        title = "vue_request_forward",
        command = "typescript.tsserverRequest",
        arguments = { command, payload },
      }, { bufnr = context.bufnr }, function(_, response)
        client:notify("tsserver/response", { { id, response and response.body } })
      end)
    end
    client.handlers["tsserver/request"] = forward
  end,
}, "install typescript-language-server; Vue server itself is already cached")

local json_system = command_path("vscode-json-language-server")
local json_script = first_readable(coc_modules .. "/coc-json/lib/server.js")
local json_cmd
local json_source
if json_system then
  json_cmd = { json_system, "--stdio" }
  json_source = "PATH"
elseif node ~= "" and json_script then
  json_cmd = { node, json_script, "--stdio" }
  json_source = "existing CoC server cache"
end
add("jsonls", "JSON", json_source, json_cmd and json_cmd[1], {
  cmd = json_cmd,
  filetypes = { "json", "jsonc" },
  init_options = { provideFormatter = true },
  root_markers = { ".git" },
}, "brew install vscode-langservers-extracted")

local rust_system = command_path("rust-analyzer")
local rust_wrapper = user_dir .. "/.vim/scripts/rust-analyzer-wrapper.sh"
local rust_analyzer = first_executable(rust_system, rust_wrapper)
add("rust_analyzer", "Rust", rust_system and "PATH" or "rustup via existing wrapper", rust_analyzer, {
  cmd = { rust_analyzer },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", "rust-project.json", ".git" },
  settings = {
    ["rust-analyzer"] = {
      cargo = { allFeatures = false },
    },
  },
}, "rustup component add rust-analyzer")

local jdtls_system = command_path("jdtls")
local jdtls_cached = coc_modules .. "/coc-java/server/bin/jdtls"
local jdtls = first_executable(jdtls_system, jdtls_cached)
local java_tooling = first_executable(
  "/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home/bin/java",
  "/Library/Java/JavaVirtualMachines/temurin-21.jdk/Contents/Home/bin/java",
  command_path("java")
)
local java_project_home = vim.env.JAVA_HOME
if not java_project_home or not executable(java_project_home .. "/bin/java") then
  java_project_home = "/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"
end
local java_available = jdtls and java_tooling
local java_config
if java_available then
  local java_settings = {
    java = {
      import = {
        gradle = {
          java = { home = java_project_home },
          arguments = "--max-workers=1 --no-parallel -Dorg.gradle.daemon.idletimeout=60000",
          jvmArguments = "-Xms128m -Xmx1g -XX:MaxMetaspaceSize=384m -XX:ActiveProcessorCount=2 -Dfile.encoding=UTF-8",
        },
      },
      configuration = {
        runtimes = {
          { name = "JavaSE-17", path = java_project_home, default = true },
        },
      },
      maxConcurrentBuilds = 1,
    },
  }

  java_config = {
    cmd = function(dispatchers, config)
      local root = config.root_dir or vim.fn.getcwd()
      -- v2 intentionally starts with a clean Eclipse workspace.  The previous
      -- cache can become unusable after Gradle projects are moved or renamed.
      local workspace = vim.fn.stdpath("cache") .. "/jdtls/workspace-v2/" .. vim.fn.sha256(root):sub(1, 16)
      vim.fn.mkdir(workspace, "p")
      return vim.lsp.rpc.start({
        jdtls,
        "--java-executable",
        java_tooling,
        "--jvm-arg=-Xms128m",
        "--jvm-arg=-Xmx1g",
        "--jvm-arg=-XX:ActiveProcessorCount=2",
        "-data",
        workspace,
      }, dispatchers, {
        cwd = root,
        env = config.cmd_env,
        detached = config.detached,
      })
    end,
    cmd_env = { JAVA_HOME = java_project_home },
    filetypes = { "java" },
    root_markers = {
      { "mvnw", "gradlew", "settings.gradle", "settings.gradle.kts", ".git" },
      { "build.xml", "pom.xml", "build.gradle", "build.gradle.kts" },
    },
    settings = java_settings,
    -- JDTLS starts the Gradle import during initialization, before the normal
    -- workspace/didChangeConfiguration notification.  Supplying the same
    -- settings here makes the resource limits effective for the first import.
    init_options = {
      settings = vim.deepcopy(java_settings),
    },
  }
end
add("jdtls", "Java", jdtls_system and "PATH" or "existing CoC server cache", java_available and jdtls or nil, java_config, "brew install jdtls")

local function unavailable_names()
  local names = {}
  for _, item in ipairs(M.status) do
    if not item.available then
      table.insert(names, item.name)
    end
  end
  return names
end

function M.start(opts)
  opts = opts or {}
  if #M.available_names == 0 then
    vim.notify("没有可用的语言服务器；运行 :NativeLspInfo 查看", vim.log.levels.ERROR)
    return
  end
  vim.g.ide_enabled = true
  vim.lsp.enable(M.available_names, true)
  if not opts.quiet then
    local missing = unavailable_names()
    local suffix = #missing > 0 and ("；未安装：" .. table.concat(missing, ", ")) or ""
    vim.notify("Neovim 原生 LSP 已开启" .. suffix)
  end
end

function M.stop(opts)
  opts = opts or {}
  vim.lsp.enable(M.available_names, false)
  vim.g.ide_enabled = false
  if not opts.quiet then
    vim.notify("Neovim 原生 LSP 已关闭")
  end
end

function M.toggle()
  if vim.g.ide_enabled then
    M.stop()
  else
    M.start()
  end
end

function M.info()
  local lines = {
    "Client: Neovim built-in LSP",
    "Completion: Neovim built-in completion",
    "IDE: " .. (vim.g.ide_enabled and "ON" or "OFF"),
    "",
    "Configured servers:",
  }
  for _, item in ipairs(M.status) do
    if item.available then
      table.insert(lines, ("  ✓ %-16s %-23s %s"):format(item.name, item.source or "", item.command))
    else
      table.insert(lines, ("  ✗ %-16s %s"):format(item.name, item.missing or "missing"))
    end
  end

  local clients = vim.lsp.get_clients()
  table.insert(lines, "")
  if #clients == 0 then
    table.insert(lines, "Active clients: none")
  else
    table.insert(lines, "Active clients:")
    for _, client in ipairs(clients) do
      table.insert(lines, ("  • %s  %s"):format(client.name, client.root_dir or "(single file)"))
    end
  end
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "Native LSP" })
  return lines
end

function M.setup()
  vim.g.ide_enabled = false
  vim.api.nvim_create_user_command("NativeLspStart", function()
    M.start()
  end, { desc = "Enable Neovim native LSP" })
  vim.api.nvim_create_user_command("NativeLspStop", function()
    M.stop()
  end, { desc = "Disable Neovim native LSP and stop servers" })
  vim.api.nvim_create_user_command("NativeLspToggle", M.toggle, { desc = "Toggle Neovim native LSP" })
  vim.api.nvim_create_user_command("NativeLspInfo", M.info, { desc = "Show native LSP server status" })
end

return M
