# Vim 配置

这是一个面向 macOS 终端 Vim 9 的模块化配置。CoC 统一负责补全、LSP、诊断、跳转和格式化；GitHub Copilot 只负责 AI 建议。

## 环境要求

- Vim 9.0.0438 或更新版本，并包含 `+job`、`+channel`
- Node.js 20 或更新版本
- Git、curl、ripgrep、Python 3、Go
- Go、Python、Java、Rust 等工具链由用户自行安装
- Java 项目使用已有的 Zulu 17；`coc-java` 的 JDT.LS 使用已有的 Zulu 21
- Rust 推荐使用 rustup，并安装 `rust-analyzer` 组件

当前 zsh 已配置 `alias vim='mvim -v'`，日常执行 `vim` 时使用的是 Homebrew MacVim 的终端模式，包含 `+python3`，因此 Vimspector 可以加载。macOS 自带的 `/usr/bin/vim` 没有 `+python3`；绕过别名直接使用它时，调试快捷键只会显示提示。

`bootstrap.sh` 只安装 Java、Python、JavaScript/TypeScript、Go 和 Rust
的编辑器插件及调试适配器，不安装或替换系统语言运行时。Markdown 与
Dockerfile 不需要源码调试器。

## 安装

配置入口是 `~/.vim/vimrc`，不要同时保留 `~/.vimrc`。

```bash
bash ~/.vim/scripts/bootstrap.sh
bash ~/.vim/scripts/health-check.sh
```

macOS 优先使用 Homebrew Python 安装调试适配器，避免系统旧 Python 的证书和架构问题。需要指定其他解释器时，可设置 `VIMSPECTOR_PYTHON`。

Java 项目和 Gradle 默认使用：

```text
/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
```

当前 JDT.LS 的部分模块要求 Java 21，因此编辑器语言服务使用本机已有的：

```text
/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home
```

这两个路径都只复用现有 JDK。需要换路径时：

```bash
VIM_JAVA_HOME=/path/to/jdk-17 \
VIM_JAVA_TOOLING_HOME=/path/to/jdk-21 \
  bash ~/.vim/scripts/bootstrap.sh
```

安装脚本会给 `coc-java` 创建一个指向现有 JDK 21 的兼容链接；该链接不
复制 JDK，也不会修改 `/Library/Java`。项目的 Java 版本仍为 17。

`bootstrap.sh` 只从官方 GitHub 下载 Vim-Plug 和声明的插件。旧镜像配置仍保留在 `config/plugins.vim` 中，但已注释：

```vim
" let g:plug_url_format = 'https://bgithub.xyz/%s'
```

## 快捷键

Leader 是反斜杠 `\`。

### 文件与搜索

| 快捷键 | 功能 |
| --- | --- |
| `\p` | 查找文件 |
| `\f` | 全局文本搜索 |
| `\b` | 缓冲区列表 |
| `\h` | 最近文件 |
| `\e` | 文件树 |
| `\c` | 命令列表 |

### CoC

| 快捷键 | 功能 |
| --- | --- |
| `gd` | 定义 |
| `gr` | 引用 |
| `gi` | 实现 |
| `K` | 文档 |
| `[g` / `]g` | 上一个/下一个诊断 |
| `\a` | Code Action |
| `\r` | 重命名 |
| `\=` | 格式化 |
| `\l` | 问题列表 |
| `\o` | 代码大纲 |

插入模式使用 `Tab` / `Shift-Tab` 选择补全项，`Enter` 确认，`Ctrl-K` 手动触发补全。`Ctrl-J` 接受 Copilot 建议；没有建议时正常换行。

### Git、文件与窗口

| 快捷键 | 功能 |
| --- | --- |
| `\gs` | Git 状态 |
| `\gd` | 当前文件 Diff |
| `\gb` | Blame |
| `\gp` | 预览当前 Hunk |
| `\w` | 保存 |
| `\q` | 安全关闭 |
| `\x` | 保存并关闭 |
| `[b` / `]b` | 上一个/下一个缓冲区 |
| `Ctrl-W h/j/k/l` | Vim 原生窗口导航 |

### 调试

| 快捷键 | 功能 |
| --- | --- |
| `\dd` | 启动或继续 |
| `\db` | 切换断点 |
| `\dn` | 单步跳过 |
| `\di` | 单步进入 |
| `\do` | 单步跳出 |
| `\ds` | 停止 |

没有配置 F2、F5、F9、F10、F11、F12 等功能键。

在 Java 文件中，`\dd` 会走 `coc-java-debug`：CoC 解析当前主类、Gradle
classpath 和项目名，再连接 Vimspector。Java 的启动配置已经全局定义，
不会向业务仓库生成 `.vimspector.json`。若 Java 服务仍在导入项目，启动
请求会自动等待，`\ds` 可取消等待。安装或更新 `coc-java-debug` 后，需要
重启 Vim，或执行 `:CocRestart`。

其余语言已安装的适配器如下：

| 语言 | 适配器 |
| --- | --- |
| Python | `debugpy` |
| JavaScript / TypeScript / Vue | `vscode-js-debug` |
| Go | `delve` |
| Rust | `CodeLLDB` |

适配器负责“怎么调试”，项目的 `.vimspector.json` 负责“启动哪个程序及
参数”。Java 已有不落盘的全局启动配置；其他语言仍可按项目添加启动配置。

以后更新已安装的适配器可执行 `:VimspectorUpdate`。

## CoC

声明的扩展覆盖 Go、Python、JavaScript/TypeScript、Vue、Java、Rust、JSON、ESLint、Prettier 和 Ruff。

常用命令：

```vim
:CocInfo
:CocList extensions
:CocOpenLog
:CocUpdate
```

Markdown 使用 Vim 语法和 Prettier 手动格式化。Dockerfile 使用 Vim 内置语法。

Rust Analyzer 通过 `scripts/rust-analyzer-wrapper.sh` 使用 rustup 的 stable 工具链，避免被其他 Rust 安装覆盖。首次使用前执行：

```bash
rustup component add rust-analyzer
```

该包装脚本只影响 CoC 启动的 Rust Analyzer，不修改全局 Shell PATH。

## 更新

```vim
:PlugUpdate
:PlugSnapshot! ~/.vim/snapshot.vim
:CocUpdate
```

更新后运行：

```bash
bash ~/.vim/tests/run.sh
bash ~/.vim/scripts/health-check.sh
git -C ~/.vim status
```

确认正常后再提交 `snapshot.vim` 和其他配置变更。

## 模板

模板位于 `templates/`：

- `py.template`
- `markdown.template`

创建对应类型的新文件时，vim-templates 会读取这些模板。

## Git 与 oh-my-zsh

`~/.vim/.git` 只管理本目录配置。oh-my-zsh 的 Git 插件只是提供 Shell 别名和提示符，两者不冲突。进入 `~/.vim` 后提示符显示分支和修改状态是正常现象。

插件目录、CoC 缓存、调试适配器、undo 和历史文件都被 `.gitignore` 排除。

## 回滚

本次迁移的完整备份位于：

```text
~/Downloads/vim-backup-20260728-145758
```

需要回滚时，先将当前 `~/.vim` 改名保存，再恢复备份中的：

```text
vimrc          -> ~/.vimrc
vim            -> ~/.vim
vim-templates  -> ~/.vim-templates
```

备份不会由安装或更新脚本自动删除。
