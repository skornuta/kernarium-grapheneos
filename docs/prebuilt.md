# Prebuilt lane

A release derived from Kernarium's published LineageOS 24 bundle, without an Android source build. `scripts/prebuilt/build.sh` runs on any x86_64 Linux host with ~10 GB free; `.github/workflows/prebuilt-release.yml` runs it on GitHub Actions and publishes a release.

## What changes

Only `product` and `system_ext` are rebuilt. `system`, `vendor`, `odm`, `init_boot`, `recovery`, the kernel and the kernel command line are the base release's bytes.

| Change | Where |
| --- | --- |
| ART: JIT off (`KGOS_JIT=off`), `speed` for install, bulk install, background dexopt, cmdline, shared libraries | `product/etc/build.prop` (`prebuilt/props/`) |
| Blur off | `product/etc/build.prop` |
| Window, transition and animator scales 0, once per data disk (global setting `kgos_ui_defaults`) | `system_ext/bin/kernarium_keyboard_default.sh`, label unchanged |
| Removed: Twelve, Etar, ExactCalculator, Camelot | `prebuilt/debloat.txt` |
| microG GmsCore + Companion (`com.android.vending`) as product priv-apps, privileged-permission allowlist generated from the APKs and framework, power-save and broadcast exemptions | `product/priv-app/`, `product/etc/{permissions,sysconfig}/` |

LineageOS's restricted signature spoofing is already in the base framework; `tools/microg.py` refuses an APK whose certificate is not the one `services.jar` trusts.

SELinux stays enforcing (a `user` build ignores `androidboot.selinux=permissive`). Files keep their extracted owners, modes, SELinux labels and capabilities; erofs-utils carries `prebuilt/patches/erofs-utils-fsck-xattrs-after-chown.patch` so that `fsck.erofs --extract` keeps `security.capability`.

Preinstalled apps keep their shipped dex code (`speed` for SystemUI and Launcher, `verify` for most others). With the JIT off, `verify` code is interpreted until background dexopt recompiles it. To compile everything at once over adb:

```sh
adb shell cmd package compile -m speed -f -a
```

## Identity

`release_id` `20261115-los24-r28-kgosN`, `product_family` `lineage-24-mainline-6.18-4k-kgos`, `build_number` `28000 + N`: above the base's 28, so Andarium treats it as an update of an existing r28 instance. Bump `KGOS_REV` in `prebuilt/config.env` for every published change.

## Install

- IPA: the release's `Andarium-1.0-15-kgosN.ipa` is the upstream IPA with `andarium-system/` replaced. Sideload it with a tool that re-signs (AltStore, SideStore, Sideloadly).
- Xcode: extract the release tarball and run `Andarium/scripts/stage-system-image.py --release <dir>` in Kernarium before building a Debug or Release configuration.
