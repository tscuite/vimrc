#!/usr/bin/env bash
set -euo pipefail

die() {
  printf 'ERROR: %s\n' "$1" >&2
  exit 1
}

find_java_home() {
  local candidate
  local candidates=()

  if [[ -n "${VIM_JAVA_HOME:-}" ]]; then
    candidates+=("${VIM_JAVA_HOME}")
  fi
  if [[ "$(uname -s)" == "Darwin" ]]; then
    candidates+=(
      "/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"
    )
  fi
  if [[ -n "${JAVA_HOME:-}" ]]; then
    candidates+=("${JAVA_HOME}")
  fi

  for candidate in "${candidates[@]}"; do
    if [[ -x "${candidate}/bin/java" && -x "${candidate}/bin/javac" ]]; then
      printf '%s\n' "${candidate}"
      return
    fi
  done

  if [[ -x /usr/libexec/java_home ]]; then
    candidate="$(/usr/libexec/java_home -v 17 2>/dev/null || true)"
    if [[ -x "${candidate}/bin/java" && -x "${candidate}/bin/javac" ]]; then
      printf '%s\n' "${candidate}"
      return
    fi
  fi

  return 1
}

java_home="$(find_java_home)" ||
  die 'Java 17 JDK not found; set VIM_JAVA_HOME to an existing JDK 17'

javac_version="$("${java_home}/bin/javac" -version 2>&1)"
java_major="${javac_version#javac }"
java_major="${java_major%%.*}"
[[ "${java_major}" == "17" ]] ||
  die "expected Java 17 at ${java_home}, found ${javac_version}"

case "$(uname -s)" in
  Darwin)
    coc_platform='darwin'
    ;;
  Linux)
    coc_platform='linux'
    ;;
  *)
    die "unsupported operating system for coc-java compatibility link: $(uname -s)"
    ;;
esac

case "$(uname -m)" in
  arm64 | aarch64)
    coc_arch='arm64'
    ;;
  x86_64 | amd64)
    coc_arch='64'
    ;;
  *)
    die "unsupported architecture for coc-java compatibility link: $(uname -m)"
    ;;
esac

coc_root="${XDG_CONFIG_HOME:-${HOME}/.config}/coc"
compat_parent="${coc_root}/extensions/coc-java-data/jdk-17.0.8"
compat_parent+="/javajre-${coc_platform}-${coc_arch}"
compat_link="${compat_parent}/jre"

mkdir -p "${compat_parent}"

if [[ -L "${compat_link}" ]]; then
  current_target="$(readlink "${compat_link}")"
  if [[ "${current_target}" != "${java_home}" ]]; then
    unlink "${compat_link}"
  fi
elif [[ -e "${compat_link}" ]]; then
  die "refusing to replace existing coc-java runtime: ${compat_link}"
fi

if [[ ! -L "${compat_link}" ]]; then
  ln -s "${java_home}" "${compat_link}"
fi

printf 'Using existing Java 17 for coc-java: %s\n' "${java_home}"
printf 'Compatibility link (contains no JDK copy): %s\n' "${compat_link}"
