# lik — Li kernel

Li-native operating system kernel sources for LiOS.

| Repo | Role |
|------|------|
| **lik** (this repo) | Kernel — boot, MM, scheduler, drivers |
| **lic** | Compiler — freestanding targets, `@hw` lowering |
| **li-os** | Distro tooling — `dev-vm.sh`, gates, CI |

## M1 bring-up

```bash
export LIC_ROOT=/path/to/lic
bash scripts/build-hello-kern.sh
bash scripts/smoke-hello-kern.sh ../build/hello_kern.elf
```

Normative ABI: [`docs/kernel-abi.md`](docs/kernel-abi.md)  
Device/port policy: [`docs/device-ports.md`](docs/device-ports.md)

## Architectures

| Arch | Status |
|------|--------|
| i686 | M1 primary (freestanding multiboot1) |
| x86_64 | planned |
| aarch64 | planned |
