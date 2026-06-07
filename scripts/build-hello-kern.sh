#!/usr/bin/env bash
# Build freestanding hello_kern.elf from lik sources using lic.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

LIC_ROOT="${LIC_ROOT:-}"
if [[ -z "${LIC_ROOT}" ]]; then
  for candidate in "${ROOT}/../lic" "/workspace/lic"; do
    if [[ -d "${candidate}/.git" ]]; then
      LIC_ROOT="${candidate}"
      break
    fi
  done
fi
[[ -n "${LIC_ROOT}" && -d "${LIC_ROOT}" ]] || {
  echo "build-hello-kern: LIC_ROOT not found (clone lic as ../lic or set LIC_ROOT=)" >&2
  exit 1
}

LIC="${LIC:-}"
if [[ -z "${LIC}" ]]; then
  for candidate in \
    "${LIC_ROOT}/build-kernel/compiler/lic/lic" \
    "${LIC_ROOT}/build-wsl/compiler/lic/lic" \
    "${LIC_ROOT}/build/compiler/lic/lic"; do
    if [[ -x "${candidate}" ]]; then
      LIC="${candidate}"
      break
    fi
  done
fi
if [[ -z "${LIC}" ]]; then
  LIC="$(command -v lic || true)"
fi
[[ -n "${LIC}" && -x "${LIC}" ]] || {
  echo "build-hello-kern: lic not found (build compiler in lic or set LIC=)" >&2
  exit 1
}

OUT="${LIOS_KERNEL_ELF:-}"
if [[ -z "${OUT}" ]]; then
  if [[ -d "${ROOT}/../build" ]]; then
    OUT="${ROOT}/../build/hello_kern.elf"
  else
    OUT="${ROOT}/build/hello_kern.elf"
  fi
fi
mkdir -p "$(dirname "${OUT}")"

SRC="${ROOT}/src/hello_kern/hello_kern.li"
[[ -f "${SRC}" ]] || { echo "build-hello-kern: missing ${SRC}" >&2; exit 1; }

echo "build-hello-kern: lik=${ROOT} lic=${LIC} out=${OUT}"
"${LIC}" build --target i686-unknown-none --allow-open-vc --no-lean-verify \
  -o "${OUT}" "${SRC}"
echo "build-hello-kern: ok → ${OUT}"
