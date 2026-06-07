# Device and I/O port policy

LiOS supports an **unlimited number of ports** at the OS/driver API level. There is no
global slot budget for devices, I/O port bindings, or MMIO regions.

## Normative rules

| Layer | Policy | Enforcement |
|-------|--------|-------------|
| Device registry | Unbounded hotplug entries | `CapDevice` per endpoint |
| I/O port bindings | Any number of `(base, len)` ranges per driver | Capability + MPU/IOMMU where applicable |
| MMIO regions | Unbounded mapped regions | `@hw.mmio_*` in proved driver code only |
| Virtio queues | Per-device count from hardware | Driver negotiates; no kernel-wide cap |
| Legacy serial/LPT | Multiple instances via ACPI/PCI | Same registry model |

## Anti-patterns (forbidden in lik `src/`)

- `MAX_DEVICES`, `MAX_IO_PORTS`, `MAX_MMIO_REGIONS`, or equivalent fixed slot tables
- Static global arrays sized by a port-count constant for the device list
- Implicit “only COM1 exists” assumptions in kernel core (COM1 is fine for M1 **smoke** only)

## Required patterns

- Growable vectors or intrusive lists for device and port-binding tables
- Hotplug via `li-dev` + `li-devd` adds endpoints without recompiling limits
- Each endpoint receives a distinct `CapDevice`; authority not slot count

## What stays finite

- **`@hw` intrinsic catalog** in lic (audited CPU/HW seam)
- **Physical x86 I/O address space** (16-bit hardware)
- **Per-endpoint authority** (capabilities required for access)

## M1 scope

M1 smoke tests one serial path (`hello_kern` on COM1). That is a **test focus**, not an
OS-wide port cap. Post-M1 work implements the growable registry under `dev/li-dev/`.

## dev-vm networking

Host TCP/UDP forwards for the dev VM must be **dynamically allocated** (ephemeral ports
or config-driven), not limited to a fixed short `hostfwd=` table. Prefer virtio user
networking plus optional tap/bridge for workloads needing many listeners.
