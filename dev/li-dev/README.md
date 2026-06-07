# li-dev (design stub)

Growable device registry for LiOS hotplug. Post-M1 implementation.

- No `MAX_DEVICES` or fixed slot tables
- Enumeration produces N `CapDevice` handles for N discovered endpoints
- See [`docs/device-ports.md`](../docs/device-ports.md)
