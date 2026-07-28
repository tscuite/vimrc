#!/usr/bin/env bash
set -euo pipefail

die() {
  printf 'ERROR: %s\n' "$1" >&2
  exit 1
}

find_java_home() {
  local major="$1"
  local environment_name="$2"
  local preferred_home="$3"
  local candidate
  local candidates=()

  if [[ -n "${!environment_name:-}" ]]; then
    candidates+=("${!environment_name}")
  fi
  if [[ -n "${preferred_home}" ]]; then
    candidates+=("${preferred_home}")
  fi
  if [[ -n "${JAVA_HOME:-}" ]]; then
    candidates+=("${JAVA_HOME}")
  fi

  for candidate in "${candidates[@]}"; do
    if [[ -x "${candidate}/bin/java" &&
      -x "${candidate}/bin/javac" &&
      "$("${candidate}/bin/javac" -version 2>&1)" == javac\ "${major}".* ]]; then
      printf '%s\n' "${candidate}"
      return
    fi
  done

  if [[ -x /usr/libexec/java_home ]]; then
    candidate="$(/usr/libexec/java_home -v "${major}" 2>/dev/null || true)"
    if [[ -x "${candidate}/bin/java" &&
      -x "${candidate}/bin/javac" &&
      "$("${candidate}/bin/javac" -version 2>&1)" == javac\ "${major}".* ]]; then
      printf '%s\n' "${candidate}"
      return
    fi
  fi

  return 1
}

project_java_home="$(find_java_home \
  17 \
  VIM_JAVA_HOME \
  '/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home')" ||
  die 'Java 17 JDK not found; set VIM_JAVA_HOME to an existing JDK 17'
tooling_java_home="$(find_java_home \
  21 \
  VIM_JAVA_TOOLING_HOME \
  '/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home')" ||
  die 'Java 21 JDK not found; set VIM_JAVA_TOOLING_HOME to an existing JDK 21'

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
  if [[ "${current_target}" != "${tooling_java_home}" ]]; then
    unlink "${compat_link}"
  fi
elif [[ -e "${compat_link}" ]]; then
  die "refusing to replace existing coc-java runtime: ${compat_link}"
fi

if [[ ! -L "${compat_link}" ]]; then
  ln -s "${tooling_java_home}" "${compat_link}"
fi

printf 'Using existing Java 21 for coc-java tooling: %s\n' \
  "${tooling_java_home}"
printf 'Using existing Java 17 for projects and Gradle: %s\n' \
  "${project_java_home}"
printf 'Compatibility link (contains no JDK copy): %s\n' "${compat_link}"
