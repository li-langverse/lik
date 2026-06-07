# Li kernel ABI

Normative kernel ABI for LiOS. Kernel source lives in **lik**; the compiler lives in **lic**.

## Target triples

| Arch | LLVM triple | M1 status |
|------|-------------|-------------|
| i686 | `i686-unknown-none` | primary bring-up |
| x86_64 | `x86_64-unknown-none` | planned |
| aarch64 | `aarch64-unknown-none` | planned |

All targets: OS = none (freestanding), environment = kernel, little-endian.

## Proof pillar

Kernel code is compiled with `lic build` and must carry proof certificates like userspace
targets. No `Any`, no unproved `unsafe`, and no silent narrowing conversions.

## Hardware intrinsics (`@hw`)

Kernel I/O uses **`@hw` intrinsics only** — no C or assembly in the kernel link graph.
The **lic** compiler lowers `@hw`; this document defines the kernel-facing surface.

Phase 1 minimum for `hello_kern`:

| Intrinsic | Purpose |
|-----------|---------|
| `@hw.outb(port, value)` | Write byte to I/O port (full 16-bit port on x86) |
| `@hw.hlt()` | Halt until interrupt |

**Compiler rule:** no whitelist of allowed port numbers at compile time; security is
capability-gated in kernel drivers (see [`device-ports.md`](device-ports.md)).

## Link model

- Entry: `_start` in `.text.boot`
- No libc, no pthread, no trusted C runtime objects
- Gate: `li-os/scripts/gates/check-zero-c.sh` on the produced ELF

## Build invocation

```bash
export LIC_ROOT=/path/to/lic
bash scripts/build-hello-kern.sh
# → ../build/hello_kern.elf (or lik/build/hello_kern.elf)
```

## Serial smoke

```bash
bash scripts/smoke-hello-kern.sh ../build/hello_kern.elf
# or: lic smoke-kernel ../build/hello_kern.elf
bash /path/to/li-os/scripts/gates/phase-p0-hello-kern-gate.sh
```

## Related repos

| Repo | Role |
|------|------|
| **lik** | Kernel source (this repo) |
| **lic** | Compiler freestanding targets + `@hw` lowering |
| **li-os** | dev-vm, gates, CI |
