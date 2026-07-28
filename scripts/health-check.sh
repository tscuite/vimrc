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
  elif command -v mvim >/dev/null 2>&1 &&
    mvim -v --version | rg -q '\+python3'; then
    pass "MacVim terminal mode has +python3 for Vimspector: $(command -v mvim)"
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
  autoload/vimconfig/debug.vim \
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

coc_config_root="${XDG_CONFIG_HOME:-${HOME:-}/.config}/coc"
java_debug_root="${coc_config_root}/extensions/node_modules/coc-java-debug"
if find "${java_debug_root}/server" \
  -maxdepth 1 \
  -type f \
  -name 'com.microsoft.java.debug.plugin-*.jar' \
  -print \
  -quit 2>/dev/null | rg -q .; then
  pass 'Java debug adapter installed through coc-java-debug'
else
  warn 'Java debug adapter missing; run :CocInstall coc-java-debug'
fi

gadget_manifest="${vim_root}/plugged/vimspector/gadgets/macos/.gadgets.json"
if [[ -r "${gadget_manifest}" ]]; then
  for adapter in debugpy delve js-debug CodeLLDB; do
    if rg -Fq "\"${adapter}\"" "${gadget_manifest}"; then
      pass "Vimspector adapter installed: ${adapter}"
    else
      warn "Vimspector adapter missing: ${adapter}"
    fi
  done
else
  warn 'Vimspector adapters are not installed; run scripts/bootstrap.sh'
fi

for optional_command in go python3 java cargo; do
  check_optional_command "${optional_command}"
done

managed_gopls="${coc_config_root}/extensions/coc-go-data/bin/gopls"
if command -v gopls >/dev/null 2>&1; then
  pass "gopls: $(command -v gopls)"
elif [[ -x "${managed_gopls}" ]]; then
  pass "gopls managed by coc-go: ${managed_gopls}"
else
  warn 'gopls not installed; activate coc-go or run :CocCommand go.install.gopls'
fi

if command -v rustup >/dev/null 2>&1 &&
  rustup run stable rustc --version >/dev/null 2>&1; then
  pass "rustc via rustup: $(rustup run stable rustc --version)"
  path_rustc="$(command -v rustc || true)"
  rustup_rustc="$(rustup which rustc 2>/dev/null || true)"
  if [[ -n "${path_rustc}" && "${path_rustc}" != "${rustup_rustc}" ]]; then
    warn 'PATH rustc is not rustup-managed; Vim Rust tooling uses the rustup toolchain'
  fi
elif command -v rustc >/dev/null 2>&1 &&
  node -e '
    const { spawnSync } = require("child_process");
    const result = spawnSync(process.argv[1], ["--version"], { stdio: "ignore" });
    process.exit(result.status === 0 ? 0 : 1);
  ' "$(command -v rustc)"; then
  pass "rustc: $(rustc --version)"
else
  warn 'no usable Rust compiler found'
fi

rust_wrapper="${vim_root}/scripts/rust-analyzer-wrapper.sh"
if command -v rust-analyzer >/dev/null 2>&1 &&
  rust-analyzer --version >/dev/null 2>&1; then
  pass "rust-analyzer: $(command -v rust-analyzer)"
elif [[ -x "${rust_wrapper}" ]] &&
  "${rust_wrapper}" --version >/dev/null 2>&1; then
  pass "rust-analyzer via rustup wrapper: ${rust_wrapper}"
else
  warn 'rust-analyzer unavailable; run rustup component add rust-analyzer'
fi

printf '\nSummary: %d required failure(s), %d warning(s)\n' \
  "${required_failures}" \
  "${warnings}"

((required_failures == 0))
