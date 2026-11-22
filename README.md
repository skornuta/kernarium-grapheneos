# kernarium-grapheneos

GrapheneOS (hardened Android 17) system bundle for Kernarium / Andarium
`1.0b15-release`: a 4 KiB-page Linux 6.18 UML guest running on non-jailbroken iOS in No-JIT
interpreter mode.

## Layout

| Path | Contents |
| --- | --- |
| `device/kernarium/graphene/` | Device tree (`graphene_andarium`), ported from Kernarium's `android/lineage-24/overlay` |
| `scripts/` | Source sync, patch, build and image-assembly scripts for the Linux build VM |
| `docs/` | Bring-up notes and reference summaries |

## Reference

- Kernarium tag: `1.0b15-release`
- Reference product: `lineage_andarium` (LineageOS 24.0 / `android-17.0.0_r1`)
- Guest kernel: Kernarium `kernel/mainline-6.18`, Android product, 4 KiB pages

## Build host

Source sync and compilation run on an x86_64 Ubuntu 24.04 VM (~350 GB disk). This repository holds
only the device tree, patches and scripts.

## Status

Bring-up: device tree port in progress. AVB off, SELinux permissive.
