#!/usr/bin/env python3
"""Execute hello_kern .text in Unicorn and capture COM1 (0x3F8) outb serial."""
from __future__ import annotations

import struct
import sys
from pathlib import Path

from unicorn import Uc, UC_ARCH_X86, UC_MODE_32, UC_HOOK_INSN
from unicorn.x86_const import UC_X86_INS_OUT, UC_X86_REG_AL, UC_X86_REG_DX, UC_X86_REG_ESP


def read_elf32(path: Path) -> tuple[int, int, bytes]:
    data = path.read_bytes()
    if data[:4] != b"\x7fELF" or data[4] != 1:
        raise SystemExit(f"{path}: expected ELF32")
    e_entry = struct.unpack_from("<I", data, 0x18)[0]
    phoff = struct.unpack_from("<I", data, 0x1C)[0]
    phentsize = struct.unpack_from("<H", data, 0x2A)[0]
    phnum = struct.unpack_from("<H", data, 0x2C)[0]
    for i in range(phnum):
        off = phoff + i * phentsize
        p_type, p_offset, p_vaddr, _p_paddr, p_filesz, _p_memsz, _p_flags, _p_align = struct.unpack_from(
            "<IIIIIIII", data, off
        )
        if p_type == 1 and p_filesz > 0:
            return e_entry, p_vaddr, data[p_offset : p_offset + p_filesz]
    raise SystemExit(f"{path}: no PT_LOAD segment")


def main() -> int:
    elf = Path(sys.argv[1] if len(sys.argv) > 1 else "/tmp/hello_kern.elf")
    if not elf.is_file():
        print(f"hello-kern-serial-smoke: missing {elf}", file=sys.stderr)
        return 1

    entry, load_addr, segment = read_elf32(elf)
    base = load_addr & ~0xFFF
    end = (load_addr + len(segment) + 0xFFF) & ~0xFFF
    size = max(end - base, 0x8000)
    stack_top = 0x00120000
    stack_base = stack_top - 0x4000

    mu = Uc(UC_ARCH_X86, UC_MODE_32)
    mu.mem_map(base, size)
    mu.mem_write(load_addr, segment)
    if stack_base < base + size:
        stack_base = (base + size + 0x1000) & ~0xFFF
        stack_top = stack_base + 0x4000
    mu.mem_map(stack_base, 0x4000)
    mu.reg_write(UC_X86_REG_ESP, stack_top - 16)

    serial = bytearray()

    def hook_out(mu_obj, _addr, _size, _user, _data):  # noqa: ANN001
        port = mu_obj.reg_read(UC_X86_REG_DX) & 0xFFFF
        val = mu_obj.reg_read(UC_X86_REG_AL) & 0xFF
        if port == 0x3F8:
            serial.append(val)

    mu.hook_add(UC_HOOK_INSN, hook_out, None, 1, 0, UC_X86_INS_OUT)

    try:
        mu.emu_start(entry, entry + len(segment), count=100_000)
    except Exception as exc:
        if "hello_kern" not in serial.decode("ascii", errors="replace"):
            print(f"hello-kern-serial-smoke: emulation stopped: {exc}", file=sys.stderr)

    text = serial.decode("ascii", errors="replace")
    print(text, end="")
    if "hello_kern" in text:
        print("hello-kern-serial-smoke: PASS", file=sys.stderr)
        return 0
    print("hello-kern-serial-smoke: FAIL — expected hello_kern on COM1", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
