# Kernarium lineage-24 reference (1.0b15-release)

Source: `Kernarium/android/lineage-24/` — product `lineage_andarium`, LineageOS 24.0 on `android-17.0.0_r1`,
lunch `lineage_andarium-cp2a-user`. Device tree is `overlay/` → `device/kernarium/andarium`.

## Storage
- System disk (GPT, 4 KiB aligned, read-only): `init_boot`, `recovery`, `system`, `system_ext`, `product`, `vendor`, `odm`.
- Data disk (GPT, 1 MiB aligned, 4–128 GiB, created by the app): `misc`, `metadata` (16 MiB ext4), `userdata` (ext4, quota).
- Immutable partitions: EROFS, `zstd,15`, pcluster 16 KiB, 4 KiB blocks; `.apex` left uncompressed.
- No super/dynamic partitions, no A/B, no OTA, no `*_dlkm`, no `system_other`. zram swap = 50% RAM.
- `init_boot` and `recovery`: boot image v4, no embedded kernel.

## Boot
- Kernel: separate `vmlinux` from `kernel/mainline-6.18 --product android`, 4 KiB pages, module-free.
- `androidboot.hardware=cutf_cvm`, `fstab_suffix=uml`, `boot_devices=uml-blkdev.0,uml-blkdev.1`,
  `selinux=enforcing`, `verifiedbootstate=orange`, `uml_bpf_interpreter=1`, `enable_bootanimation=0`.
- `BOARD_AVB_ENABLE := false`; release manifest authenticates the image instead.

## Board / product flags
- Base: `device/google/cuttlefish/vsoc_arm64_pgagnostic` + `vendor/lineage/config/common_full_tablet_wifionly.mk`.
- `TARGET_BOOTS_16K :=`, `PRODUCT_MAX_PAGE_SIZE_SUPPORTED := 16384`, `PRODUCT_NO_BIONIC_PAGE_SIZE_MACRO := true`.
- Multilib `zygote64_32`: `TARGET_2ND_ARCH := arm` (armv8-a, cortex-a53), `IGNORE_PREFER32_ON_DEVICE := true`.
- `UML_ANDROID_*` switches (consumed by patched Cuttlefish, route p0001): BUILTIN_KERNEL, STATIC_STORAGE,
  DISABLE_PROJECT_QUOTAS, DISABLE_AVF, DISABLE_IDENTITY, DISABLE_REBOOT_ESCROW, DISABLE_LEGACY_VNDK, MULTILIB,
  KEEP_ADB_SECURE, SECURITY_HALS=nonsecure; `TRUSTY_SYSTEM_VM := disabled`.
- Off: Bluetooth, telephony, NFC, UWB, Thread, biometrics, OEM lock, FRP, NNAPI, fastbootd, update_engine.
- Wi-Fi: `virt_wifi`, STA only.

## Drivers / HALs
- Graphics: virtio-gpu, `drm_hwcomposer`, `gralloc.minigbm`, `libGLESv2_kernarium` (`egl=kernarium`),
  Vulkan `vulkan.virtio` = Mesa Venus (host side Venus → KosmicKrisp), GLES 3.2, HWUI skiagl.
- Custom vendor AIDL HALs (vsock, host CID 2): sensors sub-HAL (5556), vibrator (5557, SKU `haptics`),
  gamepad via uhid (5558), thermal, GNSS (`/dev/gnss0`).
- Camera: V4L2 via `hardware/google/camera` lazy HAL; codecs: `v4l2_codec2` (H.264/HEVC).
- Audio: AIDL default HAL, virtio-snd. Health: example HAL.
- `oldapp` shim + switch for legacy native apps; recovery UI `librecovery_ui_andarium`.

## Patches
- `patches/projects.tsv` + 33 routes (`p0001`–`p0033`): Cuttlefish UML, build, frameworks/base, Settings,
  Launcher3, adbd, sepolicy, netbpfload interpreter mode, audio, minigbm, drm_hwcomposer, v4l2_codec2, lmkd.
- `third_party/mesa-venus`, `third_party/meson2hermetic`.

## Release
- `tools/install-release.py --source <abs>`: verifies a release against `metadata/accepted-release.env`
  and installs into `.build/android/releases/<directory_name>`.
- Payload: `guest/system.img`, `guest/partition-layout.json`, `boot/kernel-command-line.txt`, `kernel/{vmlinux,config,System.map,modules.builtin*}`,
  `support/{fstab.uml,vintf-manifest.xml,compatibility-matrix.xml}`, `provenance/*`.
