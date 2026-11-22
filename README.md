# kernarium-grapheneos

GrapheneOS (hardened Android 17) system bundle for Kernarium / Andarium
`1.0b15-release`: a 4 KiB-page Linux 6.18 UML guest running on non-jailbroken iOS in No-JIT
interpreter mode.

## Layout

| Path | Contents |
| --- | --- |
| `device/kernarium/graphene/` | Device tree (`graphene_andarium`), ported from Kernarium's `android/lineage-24/overlay` |
| `scripts/` | Build VM bootstrap, source sync, patch and build scripts |
| `patches/` | Route skip list and rebased series |
| `support/` | Kernel command line and disk policy |
| `docs/` | Bring-up notes and reference summaries |

## Reference

- Kernarium tag: `1.0b15-release`
- Reference product: `lineage_andarium` (LineageOS 24.0 / `android-17.0.0_r1`)
- Guest kernel: Kernarium `kernel/mainline-6.18`, Android product, 4 KiB pages

## Build host

x86_64 Ubuntu 24.04, 16+ vCPU, 64 GiB RAM (32 GiB minimum), 300 GB SSD.

```sh
curl -fsSL https://raw.githubusercontent.com/skornuta/kernarium-grapheneos/main/scripts/vm-bootstrap.sh | bash
/work/kernarium-grapheneos/scripts/go.sh            # sync, patch, build in tmux session "build"
tmux attach -t build
```

`go.sh` takes any of `sync patch build`. `GRAPHENE_REF` (default `17`), `VARIANT` (default `userdebug`) and `ALLOW_FAIL=1` pass through. Logs and `patch-report.tsv` go to `/work/logs`.

## Status

Bring-up: device tree port in progress. AVB off, SELinux permissive.
