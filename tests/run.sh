#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
vim_root="$(cd "${script_dir}/.." && pwd)"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

[[ -f "${vim_root}/vimrc" ]] || fail "missing ${vim_root}/vimrc"
[[ -f "${vim_root}/config/plugins.vim" ]] || fail "missing config/plugins.vim"
[[ -f "${vim_root}/coc-settings.json" ]] || fail "missing coc-settings.json"
[[ -f "${vim_root}/scripts/bootstrap.sh" ]] || fail "missing scripts/bootstrap.sh"
[[ -f "${vim_root}/scripts/health-check.sh" ]] || fail "missing scripts/health-check.sh"
[[ -f "${vim_root}/scripts/rust-analyzer-wrapper.sh" ]] ||
  fail "missing scripts/rust-analyzer-wrapper.sh"
[[ -f "${vim_root}/autoload/vimconfig/debug.vim" ]] ||
  fail "missing autoload/vimconfig/debug.vim"
[[ -f "${vim_root}/README.md" ]] || fail "missing README.md"
[[ -f "${vim_root}/.gitignore" ]] || fail "missing .gitignore"

error_file="$(mktemp "${TMPDIR:-/tmp}/vim-config-errors.XXXXXX")"
cleanup() {
  rm -f "${error_file}"
}
trap cleanup EXIT

if ! VIM_TEST_ERRORS="${error_file}" vim \
  -Nu "${vim_root}/vimrc" \
  -i NONE \
  -n \
  -es \
  -S "${script_dir}/assertions.vim"; then
  if [[ -s "${error_file}" ]]; then
    cat "${error_file}" >&2
  fi
  fail "Vim assertions failed"
fi

[[ ! -s "${error_file}" ]] || {
  cat "${error_file}" >&2
  fail "Vim assertions reported errors"
}

rg -Fq "\" let g:plug_url_format = 'https://bgithub.xyz/%s'" \
  "${vim_root}/config/plugins.vim" ||
  fail "disabled bgithub.xyz mirror line is missing"

if rg -n \
  '^[[:space:]]*let[[:space:]]+g:plug_url_format.*bgithub\.xyz' \
  "${vim_root}/config/plugins.vim"; then
  fail "bgithub.xyz mirror is active"
fi

if rg -n \
  "^Plug .*(YouCompleteMe|dense-analysis/ale|vim-flake8|syntastic-local-eslint|vim-codefmt|vim-maktaba)" \
  "${vim_root}/config/plugins.vim"; then
  fail "a removed completion/lint/format plugin is still declared"
fi

rg -Fq \
  'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' \
  "${vim_root}/scripts/bootstrap.sh" ||
  fail "bootstrap does not use the official Vim-Plug URL"

if rg -n 'bgithub\.xyz' "${vim_root}/scripts/bootstrap.sh"; then
  fail "bootstrap must not use bgithub.xyz"
fi

rg -Fq '/plugged/' "${vim_root}/.gitignore" ||
  fail ".gitignore must ignore downloaded plugins"
rg -Fq '/docs/' "${vim_root}/.gitignore" ||
  fail ".gitignore must keep planning documents out of the repository"
rg -Fq '\dd' "${vim_root}/README.md" ||
  fail "README must document debug mappings"
rg -Fq 'coc-go-data/bin/gopls' "${vim_root}/scripts/health-check.sh" ||
  fail "health check must recognize CoC-managed gopls"

while IFS= read -r -d '' shell_file; do
  bash -n "${shell_file}"
done < <(find "${vim_root}/scripts" "${vim_root}/tests" -type f -name '*.sh' -print0)

node -e \
  'JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"))' \
  "${vim_root}/coc-settings.json"
node -e '
  const config = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
  if (config["rust-analyzer.server.path"] !== "~/.vim/scripts/rust-analyzer-wrapper.sh") {
    process.exit(1);
  }
  if (config["java.debug.vimspector.config.createIfNotExists"] !== true) {
    process.exit(1);
  }
' "${vim_root}/coc-settings.json"

rg -Fq 'coc-java-debug' "${vim_root}/scripts/bootstrap.sh" ||
  fail "bootstrap must install coc-java-debug"
rg -Fq -- '--enable-python' "${vim_root}/scripts/bootstrap.sh" ||
  fail "bootstrap must install the Python debug adapter"
rg -Fq -- '--enable-go' "${vim_root}/scripts/bootstrap.sh" ||
  fail "bootstrap must install the Go debug adapter"
rg -Fq -- '--enable-rust' "${vim_root}/scripts/bootstrap.sh" ||
  fail "bootstrap must install the Rust debug adapter"
rg -Fq -- '--force-enable-node' "${vim_root}/scripts/bootstrap.sh" ||
  fail "bootstrap must install the JavaScript debug adapter"

if ! health_output="$("${vim_root}/scripts/health-check.sh" 2>&1)"; then
  printf '%s\n' "${health_output}" >&2
  fail "health check returned a required failure"
fi
if [[ "${health_output}" == *'Abort trap'* ]]; then
  printf '%s\n' "${health_output}" >&2
  fail "health check leaked a crashing tool diagnostic"
fi
if ! vim --version | rg -q '\+python3' &&
  command -v mvim >/dev/null 2>&1 &&
  mvim -v --version | rg -q '\+python3'; then
  [[ "${health_output}" == *'MacVim terminal mode has +python3 for Vimspector'* ]] ||
    fail "health check must recognize mvim -v as the interactive Vim"
fi

printf 'PASS: Vim configuration assertions and static checks\n'
