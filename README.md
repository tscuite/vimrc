# Vim 配置

这是一个面向 macOS Vim 9 的精简配置。`~/.vimrc` 保存插件和基础编辑，
`~/.vim/ide.vim` 保存 IDE、AI、鼠标开关及相关快捷键。

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

仓库中的 `~/.vim/vimrc` 由 `~/.vimrc` 软链接加载。首次执行初始化脚本会
自动创建该链接：

```bash
bash ~/.vim/scripts/bootstrap.sh
bash ~/.vim/scripts/health-check.sh
```

主配置会自动加载同目录下的 `ide.vim`，无需再创建额外软链接。

### Java 路径配置

Java 项目和 Gradle 默认使用：

```text
/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
```

当前 JDT.LS 的部分模块要求 Java 21，因此编辑器语言服务使用本机已有的：

```text
/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home
```

这两个路径都只复用现有 JDK，不会安装 Java。默认值位于 `~/.vim/ide.vim` 的
`g:vim_java_home` 和 `g:vim_java_tooling_home`；建议在 `~/.zshrc` 中覆盖：

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

`bootstrap.sh` 只从官方 GitHub 下载 Vim-Plug 和声明的插件。旧镜像配置
仍保留在 `~/.vimrc` 中，但已注释：

```vim
" let g:plug_url_format = 'https://bgithub.xyz/%s'
```

## 常用开关

| 快捷键 | 功能 |
| --- | --- |
| `\i` | 开启/关闭 IDE（CoC） |
| `\ai` | 开启/关闭 AI（Copilot） |
| `\m` | 开启/关闭鼠标支持 |

IDE 默认关闭，只加载基础编辑、搜索、文件树和 Git，不启动 CoC、JDT.LS
或 Gradle。普通模式按 `\i` 开启；再次按 `\i` 会关闭 IDE 并停止 CoC
和对应语言服务，无需重启 Vim。

AI 同样默认关闭。按 `\ai` 单独开启 Copilot，再次按下会关闭并停止它的
后台服务；它与 IDE 开关互不影响。

鼠标默认关闭。按 `\m` 开启后可以点击、选择和滚动；再次按下恢复纯键盘
操作。不要使用 `Ctrl-M`，它在终端 Vim 中等同于回车键。

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

以下快捷键仅在按 `\i` 开启 IDE 后生效。

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

插入模式使用 `Tab` / `Shift-Tab` 选择补全项，`Enter` 确认，`Ctrl-K`
手动触发补全。

### AI

按 `\ai` 开启 Copilot 后，插入模式使用 `Ctrl-J` 接受建议；AI 关闭或
没有建议时正常换行。

### 外部修改自动刷新

Codex 等外部 AI 修改文件后，Vim 会在回到窗口、切换缓冲区或短暂停止
输入时自动检查并重载。需要立即刷新可以执行 `:checktime`。

Vim 不会覆盖当前缓冲区中尚未保存的修改。让 AI 编辑前建议先按 `\w`
保存；如果确认放弃本地修改并读取磁盘版本，可执行 `:edit!`。

### Git 与文件

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

### 窗口切换与调整

| 快捷键 | 功能 |
| --- | --- |
| `Ctrl-W v` | 竖向拆分窗口 |
| `Ctrl-W s` | 横向拆分窗口 |
| `Ctrl-W h/j/k/l` | 切换到左/下/上/右窗口 |
| `Ctrl-W p` | 返回上一个窗口 |
| `Ctrl-W +` / `Ctrl-W -` | 增加/减小当前窗口高度 |
| `Ctrl-W >` / `Ctrl-W <` | 增加/减小当前窗口宽度 |
| `Ctrl-W =` | 所有窗口恢复等宽等高 |
| `Ctrl-W _` | 当前窗口高度最大化 |

尺寸调整可以带数字，例如 `5 Ctrl-W >` 增加 5 列宽度，`3 Ctrl-W +`
增加 3 行高度。

### 分屏跳转

先按 `Ctrl-W v`（竖向）或 `Ctrl-W s`（横向）拆分窗口，再按 `gd` 跳到
定义。返回原窗口可按 `Ctrl-W p`，也可以使用 `Ctrl-W h/j/k/l` 移动。

### 多行滚动

| 快捷键 | 功能 |
| --- | --- |
| `Ctrl-D` / `Ctrl-U` | 向下/向上滚动半页 |
| `Ctrl-F` / `Ctrl-B` | 向下/向上滚动整页 |
| `10j` / `10k` | 向下/向上移动 10 行 |
| `5 Ctrl-E` / `5 Ctrl-Y` | 窗口向下/向上滚动 5 行 |
| `zz` | 将当前行放到屏幕中间 |
| `zt` / `zb` | 将当前行放到屏幕顶部/底部 |

Mac 上这些组合键使用 Control，不是 Command。`Ctrl-W` 组合键是先按
`Ctrl-W`，松开后再按后面的按键。

### 调试分支

`main` 分支只保留 CoC/LSP 的代码跳转、补全和诊断，不包含运行或调试
功能。完整调试方案保留在 `debug` 分支；需要时执行：

```bash
git -C ~/.vim switch debug
bash ~/.vim/scripts/bootstrap.sh
```

## CoC

声明的扩展覆盖 Go、Python、JavaScript/TypeScript、Vue、Java、Rust、JSON
和 Prettier。

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
