#!/usr/bin/env bash
# Li-native virtio-mmio probe smoke via lic smoke-kernel (--stub virtio-mmio).
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
  echo "smoke-virtio-probe-kern: LIC_ROOT not found" >&2
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
  echo "smoke-virtio-probe-kern: lic not found" >&2
  exit 1
}

ELF="${LIOS_VIRTIO_PROBE_ELF:-}"
if [[ $# -gt 0 ]]; then
  ELF="$1"
  shift
fi
if [[ -z "${ELF}" ]]; then
  if [[ -f "${ROOT}/../build/virtio_probe_kern.elf" ]]; then
    ELF="${ROOT}/../build/virtio_probe_kern.elf"
  else
    ELF="${ROOT}/build/virtio_probe_kern.elf"
  fi
fi
[[ -f "${ELF}" ]] || { echo "smoke-virtio-probe-kern: missing ${ELF}" >&2; exit 1; }

TIMEOUT="${LIOS_KERNEL_SMOKE_TIMEOUT:-10}"

echo "smoke-virtio-probe-kern: lic=${LIC} elf=${ELF} timeout=${TIMEOUT}s"
export LIK_ROOT="${ROOT}"
exec "${LIC}" smoke-kernel "${ELF}" --timeout "${TIMEOUT}" --stub virtio-mmio "$@"
