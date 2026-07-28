#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
vim_root="$(cd "${script_dir}/.." && pwd)"

info() {
  printf '==> %s\n' "$1"
}

die() {
  printf 'ERROR: %s\n' "$1" >&2
  exit 1
}

for required_command in vim git curl node python3 go; do
  command -v "${required_command}" >/dev/null 2>&1 ||
    die "missing required command: ${required_command}"
done

node_major="$(node -p 'Number(process.versions.node.split(".")[0])')"
((node_major >= 20)) || die "Node.js 20 or newer is required"

mkdir -p \
  "${vim_root}/autoload" \
  "${vim_root}/plugged" \
  "${vim_root}/undo" \
  "${vim_root}/swap" \
  "${vim_root}/backup"

plug_url='https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
plug_path="${vim_root}/autoload/plug.vim"
plug_tmp="$(mktemp "${TMPDIR:-/tmp}/vim-plug.XXXXXX")"

cleanup() {
  rm -f "${plug_tmp}"
}
trap cleanup EXIT

info "Downloading Vim-Plug from official GitHub"
curl \
  --proto '=https' \
  --tlsv1.2 \
  --fail \
  --location \
  --silent \
  --show-error \
  --output "${plug_tmp}" \
  "${plug_url}"
install -m 0644 "${plug_tmp}" "${plug_path}"

info "Installing Vim plugins"
vim \
  -Nu "${vim_root}/vimrc" \
  -i NONE \
  -n \
  -es \
  '+PlugInstall --sync' \
  +qa

coc_extensions=(
  coc-go
  coc-pyright
  coc-tsserver
  @yaegassy/coc-volar
  coc-java
  coc-java-debug
  coc-rust-analyzer
  coc-json
  coc-eslint
  coc-prettier
  @yaegassy/coc-ruff
)

info "Installing CoC extensions"
vim \
  -Nu "${vim_root}/vimrc" \
  -i NONE \
  -n \
  -es \
  "+CocInstall -sync ${coc_extensions[*]}" \
  +qa

info "Configuring coc-java to reuse the existing Java 17"
"${vim_root}/scripts/use-system-java.sh"

vimspector_installer="${vim_root}/plugged/vimspector/install_gadget.py"
debugger_python="${VIMSPECTOR_PYTHON:-}"
if [[ -z "${debugger_python}" && -x /opt/homebrew/bin/python3 ]]; then
  debugger_python=/opt/homebrew/bin/python3
elif [[ -z "${debugger_python}" ]]; then
  debugger_python="$(command -v python3)"
fi

[[ -f "${vimspector_installer}" ]] ||
  die "missing Vimspector installer: ${vimspector_installer}"
[[ -x "${debugger_python}" ]] ||
  die "VIMSPECTOR_PYTHON is not executable: ${debugger_python}"

info "Installing Vimspector debug adapters"
"${debugger_python}" "${vimspector_installer}" \
  --update-gadget-config \
  --enable-python \
  --enable-go \
  --enable-rust \
  --force-enable-node

info "Writing plugin snapshot"
vim \
  -Nu "${vim_root}/vimrc" \
  -i NONE \
  -n \
  -es \
  -c "execute 'PlugSnapshot! ' . fnameescape('${vim_root}/snapshot.vim')" \
  -c qa

info "Running health check"
"${vim_root}/scripts/health-check.sh"

info "Vim bootstrap complete"
