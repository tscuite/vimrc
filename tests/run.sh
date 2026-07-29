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
  README.md \
  .gitignore \
  scripts/bootstrap.sh \
  scripts/health-check.sh \
  scripts/rust-analyzer-wrapper.sh \
  scripts/use-system-java.sh; do
  [[ -f "${vim_root}/${required_file}" ]] ||
    fail "missing ${required_file}"
done

if find "${vim_root}/config" "${vim_root}/after/ftplugin" \
  -type f -print -quit 2>/dev/null | rg -q .; then
  fail "runtime configuration must stay in vimrc"
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
  "${vim_root}/vimrc" ||
  fail "disabled bgithub.xyz mirror line is missing"
if rg -n \
  '^[[:space:]]*let[[:space:]]+g:plug_url_format.*bgithub\.xyz' \
  "${vim_root}/vimrc"; then
  fail "bgithub.xyz mirror is active"
fi

if rg -n \
  "^\\s*Plug .*(YouCompleteMe|vim-flake8|vim-codefmt|vim-markdown|vim-go|vim-monokai-pro|vim-sleuth|tabular)" \
  "${vim_root}/vimrc"; then
  fail "a redundant plugin is still declared"
fi

rg -Fq 'let g:ide_enabled = 0' "${vim_root}/vimrc" ||
  fail "IDE must be disabled by default"
rg -q '^set[[:space:]]+nonu([[:space:]]|$)' "${vim_root}/vimrc" ||
  fail "Line numbers must be disabled"
rg -Fq '<leader>i' "${vim_root}/vimrc" ||
  fail "IDE toggle mapping is missing"
rg -Fq '<leader>m' "${vim_root}/vimrc" ||
  fail "Mouse toggle mapping is missing"
if rg -Fq '/ide' "${vim_root}/vimrc" ||
  rg -Fq 'command! IDE' "${vim_root}/vimrc"; then
  fail "Only the Leader-i IDE toggle should remain"
fi
rg -Fq '`\i`' "${vim_root}/README.md" ||
  fail "README must document the IDE switch"
rg -Fq '~/.vimrc' "${vim_root}/README.md" ||
  fail "README must document the single vimrc entry point"

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
rg -Fq '/docs/' "${vim_root}/.gitignore" ||
  fail ".gitignore must keep planning documents out of the repository"

for runtime_file in \
  vimrc \
  scripts/bootstrap.sh \
  scripts/health-check.sh \
  snapshot.vim; do
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
