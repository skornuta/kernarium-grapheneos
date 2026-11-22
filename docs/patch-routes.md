# lineage-24 patch routes → GrapheneOS

| Route | Path | Patches | Base | Action |
| --- | --- | --- | --- | --- |
| p0001 | `device/google/cuttlefish` | 7 | AOSP | Port: AOSP base, rebase on GrapheneOS fork if it has one |
| p0002 | `build/make` | 4 | LineageOS | Rebase: written against LineageOS fork |
| p0003 | `packages/modules/Connectivity` | 2 | LineageOS | Rebase: written against LineageOS fork |
| p0005 | `hardware/interfaces` | 7 | LineageOS | Rebase: written against LineageOS fork |
| p0006 | `system/memory/libmeminfo` | 1 | AOSP | Port: AOSP base, rebase on GrapheneOS fork if it has one |
| p0007 | `frameworks/base` | 20 | LineageOS | Rebase: written against LineageOS fork |
| p0008 | `packages/modules/Virtualization` | 1 | AOSP | Port: AOSP base, rebase on GrapheneOS fork if it has one |
| p0009 | `packages/apps/Settings` | 2 | LineageOS | Rebase: written against LineageOS fork |
| p0010 | `packages/apps/Launcher3` | 3 | LineageOS | Rebase: written against LineageOS fork |
| p0011 | `packages/modules/adb` | 6 | LineageOS | Rebase: written against LineageOS fork |
| p0012 | `packages/providers/DownloadProvider` | 1 | LineageOS | Rebase: written against LineageOS fork |
| p0013 | `external/zstd` | 2 | LineageOS | Rebase: written against LineageOS fork |
| p0014 | `external/minigbm` | 12 | AOSP | Port: AOSP base, rebase on GrapheneOS fork if it has one |
| p0016 | `bootable/recovery` | 2 | LineageOS | Rebase: written against LineageOS fork |
| p0017 | `external/drm_hwcomposer` | 1 | AOSP | Port: AOSP base, rebase on GrapheneOS fork if it has one |
| p0018 | `external/v4l2_codec2` | 27 | LineageOS | Rebase: written against LineageOS fork |
| p0019 | `packages/providers/MediaProvider` | 1 | LineageOS | Rebase: written against LineageOS fork |
| p0020 | `system/sepolicy` | 3 | LineageOS | Rebase: written against LineageOS fork |
| p0021 | `device/lineage/sepolicy` | 1 | LineageOS | Drop — Lineage-only project |
| p0022 | `frameworks/native` | 2 | LineageOS | Rebase: written against LineageOS fork |
| p0023 | `external/erofs-utils` | 1 | AOSP | Port: AOSP base, rebase on GrapheneOS fork if it has one |
| p0024 | `packages/apps/SecureElement` | 1 | AOSP | Port: AOSP base, rebase on GrapheneOS fork if it has one |
| p0025 | `packages/apps/LineageParts` | 1 | LineageOS | Drop — LineageParts: not in GrapheneOS |
| p0026 | `packages/apps/SetupWizard` | 3 | LineageOS | Drop — Lineage SetupWizard: GrapheneOS ships SetupWizard2 |
| p0027 | `system/memory/lmkd` | 1 | AOSP | Port: AOSP base, rebase on GrapheneOS fork if it has one |
| p0028 | `frameworks/av` | 1 | LineageOS | Rebase: written against LineageOS fork |
| p0029 | `packages/modules/NetworkStack` | 1 | AOSP | Port: AOSP base, rebase on GrapheneOS fork if it has one |
| p0030 | `hardware/google/camera` | 9 | LineageOS | Rebase: written against LineageOS fork |
| p0031 | `packages/apps/Aperture` | 3 | LineageOS | Drop — Aperture: GrapheneOS ships its own Camera |
| p0032 | `system/netd` | 1 | LineageOS | Rebase: written against LineageOS fork |
| p0033 | `frameworks/opt/net/wifi` | 1 | AOSP | Port: AOSP base, rebase on GrapheneOS fork if it has one |

`third_party/mesa-venus` and `third_party/meson2hermetic` carry over unchanged.
