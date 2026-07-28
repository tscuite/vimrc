#!/usr/bin/env bash
set -uo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
vim_root="$(cd "${script_dir}/.." && pwd)"
required_failures=0
warnings=0

pass() {
  printf 'PASS  %s\n' "$1"
}

warn() {
  printf 'WARN  %s\n' "$1"
  warnings=$((warnings + 1))
}

fail() {
  printf 'FAIL  %s\n' "$1"
  required_failures=$((required_failures + 1))
}

check_required_command() {
  if command -v "$1" >/dev/null 2>&1; then
    pass "$1: $(command -v "$1")"
  else
    fail "missing required command: $1"
  fi
}

check_optional_command() {
  if command -v "$1" >/dev/null 2>&1; then
    pass "$1: $(command -v "$1")"
  else
    warn "optional command not found: $1"
  fi
}

for required_command in vim node git rg; do
  check_required_command "${required_command}"
done

if command -v vim >/dev/null 2>&1; then
  if vim -Nu NONE -i NONE -n -es \
    -c 'if !has("patch-9.0.0438") || !has("job") || !has("channel") | cquit | endif' \
    +qa; then
    pass 'Vim version and async features support CoC'
  else
    fail 'Vim 9.0.0438+ with +job and +channel is required'
  fi

  if vim --version | rg -q '\+python3'; then
    pass 'Vim has +python3 for Vimspector'
  else
    warn 'Vim lacks +python3; Vimspector mappings will show a warning'
  fi
fi

if command -v node >/dev/null 2>&1; then
  node_major="$(node -p 'Number(process.versions.node.split(".")[0])')"
  if ((node_major >= 20)); then
    pass "Node.js $(node --version)"
  else
    fail "Node.js 20+ required; found $(node --version)"
  fi
fi

for config_file in \
  vimrc \
  config/options.vim \
  config/plugins.vim \
  config/coc.vim \
  config/mappings.vim \
  coc-settings.json; do
  if [[ -r "${vim_root}/${config_file}" ]]; then
    pass "config present: ${config_file}"
  else
    fail "config missing: ${config_file}"
  fi
done

if rg -Fq "\" let g:plug_url_format = 'https://bgithub.xyz/%s'" \
  "${vim_root}/config/plugins.vim"; then
  pass 'legacy mirror is retained as a comment'
else
  fail 'commented legacy mirror line is missing'
fi

if rg -q \
  '^[[:space:]]*let[[:space:]]+g:plug_url_format.*bgithub\.xyz' \
  "${vim_root}/config/plugins.vim"; then
  fail 'legacy mirror is active'
else
  pass 'legacy mirror is disabled'
fi

if [[ -r "${vim_root}/autoload/plug.vim" ]]; then
  pass 'Vim-Plug installed'
else
  warn 'Vim-Plug not installed; run scripts/bootstrap.sh'
fi

if [[ -d "${vim_root}/plugged/coc.nvim" ]]; then
  pass 'coc.nvim plugin installed'
else
  warn 'coc.nvim plugin not installed'
fi

for optional_command in \
  go gopls python3 java cargo rustc rust-analyzer; do
  check_optional_command "${optional_command}"
done

printf '\nSummary: %d required failure(s), %d warning(s)\n' \
  "${required_failures}" \
  "${warnings}"

((required_failures == 0))
