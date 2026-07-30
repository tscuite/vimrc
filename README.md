# Neovim native LSP configuration

This configuration replaces CoC's client/completion layer with:

- Neovim 0.11 built-in LSP client (`vim.lsp.config` / `vim.lsp.enable`)
- Neovim built-in LSP completion (`vim.lsp.completion`)
- Vim's built-in default colors, using the terminal color palette
- No external Neovim plugins
- No `coc.nvim`, `nvim-cmp`, Mason, or `nvim-lspconfig`

The old `~/.vim` is intentionally left untouched as a rollback copy, but
Neovim does not load anything from it.

## Resource policy

Native LSP is off when Neovim starts, matching the old Vim configuration.
Press `\i` to start only the server matching the current file type, and press
`\i` again to stop all configured language-server processes.

Set `vim.g.native_lsp_auto_start = true` before `require("config.lsp").setup()`
in `init.lua` if automatic startup is preferred.

## Main keys

| Key | Action |
| --- | --- |
| `\i` | Start/stop native LSP |
| `gd`, `gr`, `gi`, `K` | Definition, references, implementation, hover |
| `[g`, `]g` | Previous/next diagnostic |
| `\a`, `\r`, `\=` | Code action, rename, format |
| `\l`, `\o` | Diagnostics, document symbols |
| `Tab`, `Shift-Tab`, `Enter` | Cycle/confirm native completion |
| `Ctrl-K` or `Ctrl-Space` | Trigger native completion manually |
| `\p`, `\f`, `\e` | Built-in file picker, ripgrep, file browser |

Run `:NativeLspInfo` to see available and active servers. Neovim's own health
report is available with `:checkhealth vim.lsp`.

Git and GitHub do not depend on an editor plugin. Use `:terminal` or a separate
terminal and continue with normal commands such as `git status`, `git commit`
and `git push`.
