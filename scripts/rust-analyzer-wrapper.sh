#!/usr/bin/env bash
set -euo pipefail

rustup_command="$(command -v rustup || true)"
if [[ -z "${rustup_command}" ]]; then
  printf 'ERROR: rustup is required for Rust Analyzer\n' >&2
  exit 1
fi

rustc_path="$("${rustup_command}" which rustc)"
toolchain_bin="$(dirname "${rustc_path}")"
rust_analyzer_path="${toolchain_bin}/rust-analyzer"

if [[ ! -x "${rust_analyzer_path}" ]]; then
  printf 'ERROR: run `rustup component add rust-analyzer`\n' >&2
  exit 1
fi

exec /usr/bin/env \
  PATH="${toolchain_bin}:${PATH}" \
  "${rust_analyzer_path}" \
  "$@"
