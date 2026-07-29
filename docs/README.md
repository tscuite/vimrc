# Vim 配置

面向 macOS Vim 9 的精简配置。Leader 为反斜杠 `\`，IDE、AI 和鼠标默认关闭。

## 安装

需要 Vim 9.0.0438+（包含 `+job`、`+channel`）、Node.js 20+、Git、curl
和 ripgrep。语言运行时由用户自行安装。

```bash
bash ~/.vim/scripts/bootstrap.sh
bash ~/.vim/scripts/health-check.sh
```

初始化脚本会安装 Vim-Plug、插件和 CoC 扩展，并创建
`~/.vimrc -> ~/.vim/vimrc`；不会安装 Java、Go、Python、Rust 或调试器。

配置文件：

- `config/plugins.vim`：插件
- `config/settings.vim`：基础设置
- `config/mappings.vim`：快捷键
- `config/ide.vim`：CoC、Java 和功能开关
- `config/filetypes.vim`：语言缩进
- `config/autocmds.vim`：自动事件

修改配置后重启 Vim，或执行 `:source ~/.vimrc`。

## Java

不固定厂商和安装目录：

- 项目和 Gradle 优先使用当前终端的 `$JAVA_HOME`，未设置时自动选择 Java 17。
- JDT.LS 自动选择本机 Java 21；它和项目 JDK 可以不同。

建议在 `~/.zshrc` 设置项目 JDK：

```zsh
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
```

`bootstrap.sh` 会调用 `scripts/use-system-java.sh` 让 `coc-java` 复用已有
Java 21，不会复制或安装 JDK。

## 使用

按 `\i` 开启或关闭 CoC。关闭时不会启动 JDT.LS、Gradle 或其他语言服务。
按 `\\` 开启或关闭 Copilot；插件按需加载，关闭时同时停止其后台进程。
首次使用先开启 AI，再执行 `:Copilot setup` 完成登录。
外部工具修改文件后 Vim 会自动检查；立即刷新使用 `:checktime`，确认放弃
未保存内容并重新读取磁盘文件使用 `:edit!`。

| 分类 | 快捷键 / 命令 | 功能 |
| --- | --- | --- |
| 开关 | `\i` | 开启/关闭 IDE（CoC） |
| 开关 | `\\` | 开启/关闭 AI（Copilot） |
| 开关 | `\m` | 开启/关闭鼠标 |
| 文件 | `\p` | 查找文件 |
| 文件 | `\f` | 全局文本搜索 |
| 文件 | `\b` | 缓冲区列表 |
| 文件 | `\h` | 最近文件 |
| 文件 | `\e` | 文件树 |
| 文件树 | `Enter` | 打开选中的文件或目录 |
| 文件树 | `u` | 返回上一级目录 |
| 文件树 | `Ctrl-W h` | 从文件返回左侧目录窗口 |
| 文件 | `\c` | 命令列表 |
| 文件 | `\w` / `\q` / `\x` | 保存 / 关闭 / 保存并关闭 |
| 文件 | `[b` / `]b` | 上一个/下一个缓冲区 |
| 跳转 | `Ctrl-O` / `Ctrl-I` | 返回上一个/前进到下一个位置 |
| 跳转 | `Ctrl-^` / `:b#` | 切换到上一个缓冲区 |
| 文件 | `:checktime` | 立即检查外部文件修改 |
| IDE | `gd` / `gr` / `gi` | 定义 / 引用 / 实现 |
| IDE | `K` | 查看文档 |
| IDE | `[g` / `]g` | 上一个/下一个诊断 |
| IDE | `\a` | Code Action |
| IDE | `\r` | 重命名 |
| IDE | `\=` | 格式化 |
| IDE | `\l` / `\o` | 诊断列表 / 代码大纲 |
| 补全 | `Tab` / `Shift-Tab` | 选择下一个/上一个候选 |
| 补全 | `Enter` / `Ctrl-K` | 确认 / 手动触发补全 |
| Git | `\gs` | Git 状态 |
| Git | `\gd` / `\gb` / `\gp` | Diff / Blame / 预览 Hunk |
| 编辑 | `gcc` / `gc` | 注释当前行 / 选中内容 |
| 窗口 | `Ctrl-W v` / `Ctrl-W s` | 竖向/横向拆分 |
| 窗口 | `Ctrl-W h/j/k/l` | 切换窗口 |
| 窗口 | `Ctrl-W p` | 返回上一个窗口 |
| 窗口 | `Ctrl-W +` / `Ctrl-W -` | 增加/减小高度 |
| 窗口 | `Ctrl-W >` / `Ctrl-W <` | 增加/减小宽度 |
| 窗口 | `Ctrl-W =` | 所有窗口等宽等高 |
| 窗口 | `Ctrl-W _` / `Ctrl-W \|` | 高度/宽度最大化 |
| 滚动 | `Ctrl-D` / `Ctrl-U` | 向下/向上半页 |
| 滚动 | `Ctrl-F` / `Ctrl-B` | 向下/向上整页 |
| 滚动 | `10j` / `10k` | 向下/向上移动 10 行 |
| 滚动 | `5 Ctrl-E` / `5 Ctrl-Y` | 窗口向下/向上滚动 5 行 |
| 滚动 | `zz` / `zt` / `zb` | 当前行置于中间/顶部/底部 |

Mac 上表中的 `Ctrl` 是 Control，不是 Command。`Ctrl-W` 组合键先按
`Ctrl-W`，松开后再按后一个键；尺寸调整可以加数字，例如 `5 Ctrl-W >`。

## 语言与维护

CoC 支持 Go、Python、JavaScript/TypeScript、Vue、Java、Rust、JSON 和
Prettier。Rust 首次使用前执行：

```bash
rustup component add rust-analyzer
```

常用维护命令：

```vim
:CocInfo
:CocUpdate
:Copilot status
:PlugUpdate
:PlugSnapshot! ~/.vim/snapshots/snapshot.vim
```

更新后检查：

```bash
bash ~/.vim/tests/run.sh
bash ~/.vim/scripts/health-check.sh
git -C ~/.vim status
```

`main` 分支只保留补全和跳转；调试配置保存在 `debug` 分支。Vim 中的 Git
插件与 oh-my-zsh 的 Git 别名和提示符互不冲突。
