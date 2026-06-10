#!/usr/bin/env bash
# Build mm_bump_kern.elf for M2 P3 gate.
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
  echo "build-mm-bump-kern: LIC_ROOT not found" >&2
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
  echo "build-mm-bump-kern: lic not found" >&2
  exit 1
}

OUT="${LIOS_MM_BUMP_ELF:-}"
if [[ -z "${OUT}" ]]; then
  if [[ -d "${ROOT}/../build" ]]; then
    OUT="${ROOT}/../build/mm_bump_kern.elf"
  else
    OUT="${ROOT}/build/mm_bump_kern.elf"
  fi
fi
mkdir -p "$(dirname "${OUT}")"

SRC="${ROOT}/src/mm_bump_kern/mm_bump_kern.li"
[[ -f "${SRC}" ]] || { echo "build-mm-bump-kern: missing ${SRC}" >&2; exit 1; }

echo "build-mm-bump-kern: lik=${ROOT} lic=${LIC} out=${OUT}"
export LI_REPO_ROOT="${LIC_ROOT}"
export LIK_ROOT="${ROOT}"
export LI_KERNEL_LINK_SCRIPT="${ROOT}/arch/i686/link.ld"
"${LIC}" build --target i686-unknown-none --allow-open-vc --no-lean-verify \
  -o "${OUT}" "${SRC}"
echo "build-mm-bump-kern: ok → ${OUT}"
