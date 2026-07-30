# Neovim / LazyVim 配置

这是基于 [LazyVim](https://www.lazyvim.org/) 的个人 Neovim 配置。

## 先记住两个前缀

- `<leader>` 是空格键。比如 `<leader>e` 就是依次按 `Space`、`e`。
- `\` 保留给旧 Vim 快捷键。比如 `\q` 就是依次按反斜杠、`q`。
- 不记得快捷键时，按一下 `Space` 停顿片刻可查看 WhichKey 提示；`<leader>sk` 可搜索全部快捷键。
- 鼠标默认关闭；需要 Neovim 接管鼠标时，按 `\m` 临时开启，再按一次关闭。
- LSP 默认关闭；需要代码跳转、补全和诊断时，按 `\i` 开启，再按一次关闭。

## 切换主题

- 按 `<leader>uC`（`Space`、`u`、大写 `C`）打开主题选择器。
- 用 `j` / `k` 选择并实时预览，`Enter` 应用并保存，`Esc` 取消且不修改已保存主题。
- 第一次使用时的默认主题是透明背景的 `tokyonight-moon`；以后启动会自动恢复上次按 `Enter` 保存的主题。
- 所有主题（包括选择器中的实时预览）都会沿用终端的透明背景。
- 已安装的主题家族：
  - TokyoNight：`tokyonight-day`、`tokyonight-moon`、`tokyonight-night`、`tokyonight-storm`
  - Catppuccin：`catppuccin-latte`、`catppuccin-frappe`、`catppuccin-macchiato`、`catppuccin-mocha`
  - Rose Pine：`rose-pine-main`、`rose-pine-moon`、`rose-pine-dawn`
  - Kanagawa：`kanagawa-wave`、`kanagawa-dragon`、`kanagawa-lotus`
  - Nightfox：`nightfox`、`dayfox`、`dawnfox`、`duskfox`、`nordfox`、`terafox`、`carbonfox`
  - Gruvbox：`gruvbox`
- 想恢复默认主题时，在选择器中重新选择 `tokyonight-moon` 并按 `Enter`。

## 打开、进入和关闭文件

| 操作 | 快捷键 |
| --- | --- |
| 从当前目录启动 | 终端执行 `nvim .` |
| 查找并打开文件 | `<leader><leader>`，输入文件名后按 `Enter` |
| 显示/隐藏左侧目录 | `<leader>e` 或 `\e` |
| 在目录中移动 | `j` / `k` |
| 展开目录或打开文件 | `Enter` 或 `l` |
| 收起目录 | `h` |
| 从左侧目录进入编辑区 | `<C-l>` |
| 从编辑区回到左侧目录 | `<C-h>` |
| 关闭当前文件，保留 Neovim | `<leader>bd` |
| 关闭当前文件及其窗口 | `<leader>bD` |
| 关闭其他文件 | `<leader>bo` |
| 上一个/下一个文件 | `<S-h>` / `<S-l>`，也可用 `[b` / `]b` |
| 退出当前窗口 | `\q` 或 `:q` |
| 保存并退出 | `\x` 或 `:wq` |
| 退出全部窗口 | `<leader>qq` |

`<leader>bd` 删除的是当前 buffer，最适合“只关闭这一个文件”；`:q` 关闭的是当前窗口。

## 编辑与保存

| 操作 | 快捷键 |
| --- | --- |
| 进入插入模式 | `i` |
| 回到普通模式 | `Esc` |
| 保存 | `<C-s>` 或 `\w` |
| 撤销/重做 | `u` / `<C-r>` |
| 格式化 | `\=` |
| 行注释/取消注释 | `gcc` |
| 选中后注释 | `gc` |

## 查找

| 操作 | 快捷键 |
| --- | --- |
| 查找项目文件 | `<leader><leader>` 或 `\p` |
| 全项目搜索文字 | `<leader>/` 或 `\f` |
| 查看已打开文件 | `<leader>,` 或 `\b` |
| 查看最近文件 | `<leader>fr` 或 `\h` |
| 搜索命令 | `\c` |
| 当前文件内搜索 | `/`，输入内容后按 `Enter` |
| 下一个/上一个搜索结果 | `n` / `N` |

## 代码跳转与 LSP

这些快捷键需要当前文件已经连接对应语言服务器。首次进入 Neovim 后先按 `\i` 开启，
可用 `<leader>cl` 查看连接状态。

| 操作 | 快捷键 |
| --- | --- |
| 跳到定义 | `gd` |
| 查找所有引用 | `gr` |
| 跳到实现 | `gi` 或 `gI` |
| 跳到类型定义 | `gy` |
| 跳到声明 | `gD` |
| 返回跳转前位置 | `<C-o>` |
| 向前恢复跳转 | `<C-i>` |
| 查看符号说明 | `K` |
| 重命名符号 | `<leader>cr` 或 `\r` |
| 代码操作 | `<leader>ca` 或 `\a` |
| 当前文件诊断 | `<leader>xX` |
| 全项目诊断 | `<leader>xx` 或 `\l` |
| 文档符号 | `<leader>cs` 或 `\o` |

Java 使用 `jdtls`。语言服务器由本机 Java 21 启动，Gradle 项目使用本机 `JAVA_HOME`（当前为 Java 17）。
退出 Neovim 时会显式关闭 `jdtls`，Gradle 导入也禁用了常驻 daemon，避免 Java 进程残留。
同时禁止在源码目录生成 Eclipse 的 `.project`、`.classpath` 和 `.settings` 元数据。

## 窗口

| 操作 | 快捷键 |
| --- | --- |
| 移动到左/下/上/右窗口 | `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` |
| 下方分屏 | `<leader>-` |
| 右侧分屏 | `<leader>\|` |
| 关闭当前窗口 | `<leader>wd` |
| 最大化/恢复当前窗口 | `<leader>wm` |

## 插件与工具

| 操作 | 快捷键 |
| --- | --- |
| 打开插件管理器 | `<leader>l` |
| 打开 Mason 工具管理器 | `<leader>cm` |
| 选择并预览主题 | `<leader>uC` |
| Flash 快速跳转 | `s`，输入目标字符后选择标签 |
| Git 界面 | `<leader>gg` |
| 打开终端 | `<leader>ft` |

## 保留的旧 Vim 快捷键

| 快捷键 | 操作 |
| --- | --- |
| `\p` / `\f` / `\b` / `\h` | 文件 / 搜索 / buffer / 最近文件 |
| `\e` / `\c` | 左侧目录 / 命令 |
| `\w` / `\q` / `\x` | 保存 / 退出 / 保存并退出 |
| `\a` / `\r` / `\=` | 代码操作 / 重命名 / 格式化 |
| `\l` / `\o` | 诊断 / 文档符号 |
| `\i` / `\m` | 开关 LSP（默认关闭）/ 开关鼠标（默认关闭） |
