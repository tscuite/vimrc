# Vim 配置

这是一个面向 macOS 终端 Vim 9 的模块化配置。CoC 统一负责补全、LSP、诊断、跳转和格式化；GitHub Copilot 只负责 AI 建议。

## 环境要求

- Vim 9.0.0438 或更新版本，并包含 `+job`、`+channel`
- Node.js 20 或更新版本
- Git、curl、ripgrep
- Go、Python、Java、Rust 等工具链按实际项目安装

当前机器的 Vim 没有 `+python3`。这不影响 CoC 和普通编辑，但 Vimspector 暂时不可用；使用调试快捷键时只会显示提示。以后安装带 `+python3` 的 Vim 后无需修改快捷键。

## 安装

配置入口是 `~/.vim/vimrc`，不要同时保留 `~/.vimrc`。

```bash
bash ~/.vim/scripts/bootstrap.sh
bash ~/.vim/scripts/health-check.sh
```

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

## CoC

声明的扩展覆盖 Go、Python、JavaScript/TypeScript、Vue、Java、Rust、JSON、ESLint、Prettier 和 Ruff。

常用命令：

```vim
:CocInfo
:CocList extensions
:CocOpenLog
:CocUpdate
```

Markdown 使用 Vim 语法和 Prettier 手动格式化。Dockerfile 使用 Vim 内置语法。Rust 配置已经存在；如果缺少 `rustc` 或 `rust-analyzer`，健康检查会给出警告，不会自动安装系统工具链。

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
