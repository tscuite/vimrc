#!/usr/bin/env bash
set -euo pipefail

die() {
  printf 'ERROR: %s\n' "$1" >&2
  exit 1
}

find_macos_java() {
  [[ -x /usr/libexec/java_home ]] || return 1
  /usr/libexec/java_home -v "$1" 2>/dev/null
}

project_java_home="${JAVA_HOME:-}"
if [[ ! -x "${project_java_home}/bin/java" ||
  ! -x "${project_java_home}/bin/javac" ]]; then
  project_java_home="$(find_macos_java 17 || true)"
fi
[[ -x "${project_java_home}/bin/java" &&
  -x "${project_java_home}/bin/javac" ]] ||
  die 'Project JDK not found; set JAVA_HOME or install Java 17'

tooling_java_home="$(find_macos_java 21 || true)"
[[ -x "${tooling_java_home}/bin/java" &&
  -x "${tooling_java_home}/bin/javac" ]] ||
  die 'Java 21 JDK not found; install Java 21 for JDT.LS'

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
