# Vim 配置

这是一个面向 macOS 终端 Vim 9 的模块化配置。CoC 统一负责补全、LSP、诊断、跳转和格式化；GitHub Copilot 只负责 AI 建议。

## 环境要求

- Vim 9.0.0438 或更新版本，并包含 `+job`、`+channel`
- Node.js 20 或更新版本
- Git、curl、ripgrep
- Go、Python、Java、Rust 等工具链由用户自行安装
- Java 项目使用已有的 Zulu 17；`coc-java` 的 JDT.LS 使用已有的 Zulu 21
- Rust 推荐使用 rustup，并安装 `rust-analyzer` 组件

`bootstrap.sh` 只安装 Java、Python、JavaScript/TypeScript、Go 和 Rust
的编辑器插件和语言服务，不安装或替换系统语言运行时，也不安装调试器。

## 安装

配置入口是 `~/.vim/vimrc`，不要同时保留 `~/.vimrc`。

```bash
bash ~/.vim/scripts/bootstrap.sh
bash ~/.vim/scripts/health-check.sh
```

### Java 路径配置

Java 项目和 Gradle 默认使用：

```text
/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
```

当前 JDT.LS 的部分模块要求 Java 21，因此编辑器语言服务使用本机已有的：

```text
/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home
```

这两个路径都只复用现有 JDK，不会安装 Java。仓库内的默认路径设置在：

- `config/coc.vim`
  - `g:vim_java_home`：项目、Gradle 和默认 `JavaSE-17` 运行时
  - `g:vim_java_tooling_home`：CoC 的 JDT.LS 语言服务
- `scripts/use-system-java.sh`
  - 为当前版本的 `coc-java` 创建兼容链接时使用相同的默认路径

`coc-settings.json` 中没有写死 Java 的绝对路径。通常不需要直接修改上述
两个文件，建议在 `~/.zshrc` 中覆盖：

```zsh
export VIM_JAVA_HOME=/path/to/jdk-17
export VIM_JAVA_TOOLING_HOME=/path/to/jdk-21
```

让当前终端立即读取新配置，然后更新 `coc-java` 的兼容链接：

```bash
source ~/.zshrc
bash ~/.vim/scripts/use-system-java.sh
```

最后重启 Vim，或者在 Vim 中执行：

```vim
:CocRestart
```

临时指定路径并执行完整初始化也可以：

```bash
VIM_JAVA_HOME=/path/to/jdk-17 \
VIM_JAVA_TOOLING_HOME=/path/to/jdk-21 \
  bash ~/.vim/scripts/bootstrap.sh
```

初始化脚本会给 `coc-java` 创建一个指向现有 JDK 21 的兼容链接；该链接不
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
| `Ctrl-W v` | 竖向拆分窗口 |
| `Ctrl-W s` | 横向拆分窗口 |
| `Ctrl-W h/j/k/l` | Vim 原生窗口导航 |

### 分屏跳转

先按 `Ctrl-W v`（竖向）或 `Ctrl-W s`（横向）拆分窗口，再按 `gd` 跳到
定义。返回原窗口可按 `Ctrl-W p`，也可以使用 `Ctrl-W h/j/k/l` 移动。

`main` 分支只保留 CoC/LSP 的代码跳转、补全和诊断，不包含运行或调试
功能。完整调试方案保留在 `debug` 分支；需要时执行：

```bash
git -C ~/.vim switch debug
bash ~/.vim/scripts/bootstrap.sh
```

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

插件目录、CoC 缓存、undo 和历史文件都被 `.gitignore` 排除。

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
