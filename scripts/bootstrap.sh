#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
vim_root="$(cd "${script_dir}/.." && pwd)"
vimrc_link="${HOME}/.vimrc"

info() {
  printf '==> %s\n' "$1"
}

die() {
  printf 'ERROR: %s\n' "$1" >&2
  exit 1
}

for required_command in vim git curl node; do
  command -v "${required_command}" >/dev/null 2>&1 ||
    die "missing required command: ${required_command}"
done

if [[ "${vim_root}" == "${HOME}/.vim" ]]; then
  if [[ ! -e "${vimrc_link}" && ! -L "${vimrc_link}" ]]; then
    info "Linking ~/.vimrc to ~/.vim/vimrc"
    ln -s "${vim_root}/vimrc" "${vimrc_link}"
  elif [[ ! -L "${vimrc_link}" ||
    "$(readlink "${vimrc_link}")" != "${vim_root}/vimrc" ]]; then
    die "${vimrc_link} already exists and is not managed by this repository"
  fi
fi

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
  --cmd 'let g:enable_ide = 1' \
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
  coc-rust-analyzer
  coc-json
  coc-eslint
  coc-prettier
  @yaegassy/coc-ruff
)

info "Installing CoC extensions"
vim \
  --cmd 'let g:enable_ide = 1' \
  -Nu "${vim_root}/vimrc" \
  -i NONE \
  -n \
  -es \
  "+CocInstall -sync ${coc_extensions[*]}" \
  +qa

info "Configuring coc-java to reuse the existing Java 17 and Java 21"
"${vim_root}/scripts/use-system-java.sh"

info "Writing plugin snapshot"
vim \
  --cmd 'let g:enable_ide = 1' \
  -Nu "${vim_root}/vimrc" \
  -i NONE \
  -n \
  -es \
  -c "execute 'PlugSnapshot! ' . fnameescape('${vim_root}/snapshot.vim')" \
  -c qa

info "Running health check"
"${vim_root}/scripts/health-check.sh"

info "Vim bootstrap complete"
