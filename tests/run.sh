#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
vim_root="$(cd "${script_dir}/.." && pwd)"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

for required_file in \
  vimrc \
  config/plugins.vim \
  config/settings.vim \
  config/mappings.vim \
  config/ide.vim \
  config/filetypes.vim \
  config/autocmds.vim \
  docs/README.md \
  snapshots/snapshot.vim \
  .gitignore \
  scripts/bootstrap.sh \
  scripts/health-check.sh \
  scripts/rust-analyzer-wrapper.sh \
  scripts/use-system-java.sh; do
  [[ -f "${vim_root}/${required_file}" ]] ||
    fail "missing ${required_file}"
done

if find "${vim_root}/after/ftplugin" \
  -type f -print -quit 2>/dev/null | rg -q .; then
  fail "legacy after/ftplugin configuration must stay removed"
fi

error_file="$(mktemp "${TMPDIR:-/tmp}/vim-config-errors.XXXXXX")"
cleanup() {
  rm -f "${error_file}"
}
trap cleanup EXIT

run_assertions() {
  local mode="$1"
  shift
  : >"${error_file}"
  if ! VIM_TEST_ERRORS="${error_file}" vim "$@" \
    -Nu "${vim_root}/vimrc" \
    -i NONE \
    -n \
    -es \
    -S "${script_dir}/assertions.vim"; then
    [[ ! -s "${error_file}" ]] || cat "${error_file}" >&2
    fail "Vim assertions failed in ${mode} mode"
  fi
  [[ ! -s "${error_file}" ]] || {
    cat "${error_file}" >&2
    fail "Vim assertions reported errors in ${mode} mode"
  }
}

run_assertions lightweight

rg -Fq "\" let g:plug_url_format = 'https://bgithub.xyz/%s'" \
  "${vim_root}/config/plugins.vim" ||
  fail "disabled bgithub.xyz mirror line is missing"
if rg -n \
  '^[[:space:]]*let[[:space:]]+g:plug_url_format.*bgithub\.xyz' \
  "${vim_root}/config/plugins.vim"; then
  fail "bgithub.xyz mirror is active"
fi

if rg -n \
  "^\\s*Plug .*(YouCompleteMe|vim-flake8|vim-codefmt|vim-markdown|vim-go|vim-monokai-pro|vim-sleuth|tabular)" \
  "${vim_root}/config/plugins.vim"; then
  fail "a redundant plugin is still declared"
fi

rg -Fq 'let g:ide_enabled = 0' "${vim_root}/config/ide.vim" ||
  fail "IDE must be disabled by default"
rg -Fq 'let g:ai_enabled = 0' "${vim_root}/config/ide.vim" ||
  fail "AI must be disabled by default"
rg -q '^set[[:space:]].*\bnonu\b' "${vim_root}/config/settings.vim" ||
  fail "Line numbers must be disabled"
if rg -n \
  '^[[:space:]]*(set[[:space:]]+(no)?termguicolors|set[[:space:]]+background=|(silent![[:space:]]+)?colorscheme)' \
  "${vim_root}/config/settings.vim"; then
  fail "Terminal colors must not be overridden"
fi
rg -Fq '<leader>i' "${vim_root}/config/mappings.vim" ||
  fail "IDE toggle mapping is missing"
rg -Fq '<leader>ai' "${vim_root}/config/mappings.vim" ||
  fail "AI toggle mapping is missing"
rg -Fq '<leader>m' "${vim_root}/config/mappings.vim" ||
  fail "Mouse toggle mapping is missing"
ide_function="$(sed -n '/^function! TscuiteToggleIDE()/,/^endfunction$/p' \
  "${vim_root}/config/ide.vim")"
ai_function="$(sed -n '/^function! TscuiteToggleAI()/,/^endfunction$/p' \
  "${vim_root}/config/ide.vim")"
[[ "${ide_function}" != *Copilot* ]] ||
  fail "IDE toggle must not control Copilot"
[[ "${ai_function}" != *Coc* ]] ||
  fail "AI toggle must not control CoC"
if rg -n \
  '^[[:space:]]*(nnoremap|noremap|nmap)[[:space:]].*/ide' \
  "${vim_root}/vimrc" "${vim_root}/config/mappings.vim" ||
  rg -Fq 'command! IDE' \
  "${vim_root}/vimrc" "${vim_root}/config/ide.vim" \
  "${vim_root}/config/mappings.vim"; then
  fail "Only the Leader-i IDE toggle should remain"
fi
rg -Fq "g:vim_config_root . '/config/ide.vim'" "${vim_root}/vimrc" ||
  fail "vimrc must source ide.vim"
rg -Fq "g:vim_config_root . '/config/plugins.vim'" "${vim_root}/vimrc" ||
  fail "vimrc must source plugins.vim"
rg -Fq "g:vim_config_root . '/config/settings.vim'" "${vim_root}/vimrc" ||
  fail "vimrc must source settings.vim"
rg -Fq "g:vim_config_root . '/config/mappings.vim'" "${vim_root}/vimrc" ||
  fail "vimrc must source mappings.vim"
rg -Fq "g:vim_config_root . '/config/filetypes.vim'" "${vim_root}/vimrc" ||
  fail "vimrc must source filetypes.vim"
rg -Fq "g:vim_config_root . '/config/autocmds.vim'" "${vim_root}/vimrc" ||
  fail "vimrc must source autocmds.vim"
(( "$(wc -l <"${vim_root}/vimrc")" <= 10 )) ||
  fail "vimrc must remain a small loader"
if rg -n \
  'g:coc_global_extensions|function! s:Toggle(IDE|AI|Mouse)' \
  "${vim_root}/vimrc"; then
  fail "IDE, AI, or mouse configuration remains in vimrc"
fi
if rg -n 'autocmd FileType' "${vim_root}/vimrc"; then
  fail "FileType configuration remains in vimrc"
fi
if rg -n \
  '^[[:space:]]*(noremap|nnoremap|inoremap|xnoremap|nmap|imap|xmap)[[:space:]]' \
  "${vim_root}/config/plugins.vim" \
  "${vim_root}/config/settings.vim" \
  "${vim_root}/config/ide.vim" \
  "${vim_root}/config/filetypes.vim" \
  "${vim_root}/config/autocmds.vim"; then
  fail "Shortcut configuration must stay in mappings.vim"
fi
rg -Fq '`\i`' "${vim_root}/docs/README.md" ||
  fail "README must document the IDE switch"
rg -Fq '`\ai`' "${vim_root}/docs/README.md" ||
  fail "README must document the AI switch"
rg -Fq 'FocusGained,BufEnter,CursorHold,CursorHoldI' \
  "${vim_root}/config/autocmds.vim" ||
  fail "External file changes must be checked while Vim is idle"
rg -Fq ':checktime' "${vim_root}/docs/README.md" ||
  fail "README must document manual file refresh"
rg -Fq '~/.vimrc' "${vim_root}/docs/README.md" ||
  fail "README must document the single vimrc entry point"
for documented_config in \
  plugins.vim \
  settings.vim \
  mappings.vim \
  ide.vim \
  filetypes.vim \
  autocmds.vim; do
  rg -Fq "config/${documented_config}" "${vim_root}/docs/README.md" ||
    fail "README must document config/${documented_config}"
done

rg -Fq \
  'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' \
  "${vim_root}/scripts/bootstrap.sh" ||
  fail "bootstrap does not use the official Vim-Plug URL"
if rg -n 'bgithub\.xyz' "${vim_root}/scripts/bootstrap.sh"; then
  fail "bootstrap must not use bgithub.xyz"
fi
rg -Fq 'scripts/use-system-java.sh' "${vim_root}/scripts/bootstrap.sh" ||
  fail "bootstrap must configure coc-java to use the existing JDK"
rg -Fq 'coc-go-data/bin/gopls' "${vim_root}/scripts/health-check.sh" ||
  fail "health check must recognize CoC-managed gopls"

rg -Fq '/plugged/' "${vim_root}/.gitignore" ||
  fail ".gitignore must ignore downloaded plugins"
rg -Fq '/docs/plans/' "${vim_root}/.gitignore" ||
  fail ".gitignore must keep planning documents out of the repository"

for runtime_file in \
  vimrc \
  config/plugins.vim \
  config/settings.vim \
  config/mappings.vim \
  config/ide.vim \
  config/filetypes.vim \
  config/autocmds.vim \
  scripts/bootstrap.sh \
  scripts/health-check.sh \
  snapshots/snapshot.vim; do
  if rg -n -i \
    'vimspector|coc-java-debug|debugpy|vscode-js-debug|codelldb' \
    "${vim_root}/${runtime_file}"; then
    fail "debug integration remains in ${runtime_file}"
  fi
done

while IFS= read -r -d '' shell_file; do
  bash -n "${shell_file}"
done < <(find "${vim_root}/scripts" "${vim_root}/tests" \
  -type f -name '*.sh' -print0)

if ! health_output="$("${vim_root}/scripts/health-check.sh" 2>&1)"; then
  printf '%s\n' "${health_output}" >&2
  fail "health check returned a required failure"
fi
if [[ "${health_output}" == *'Abort trap'* ]]; then
  printf '%s\n' "${health_output}" >&2
  fail "health check leaked a crashing tool diagnostic"
fi

printf 'PASS: Vim configuration assertions and static checks\n'
