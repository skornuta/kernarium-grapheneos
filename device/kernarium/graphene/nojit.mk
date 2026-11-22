# SPDX-License-Identifier: Apache-2.0

PRODUCT_DEX_PREOPT_DEFAULT_COMPILER_FILTER := speed
PRODUCT_SYSTEM_SERVER_COMPILER_FILTER := speed
PRODUCT_ALWAYS_PREOPT_EXTRACTED_APK := true

PRODUCT_SYSTEM_PROPERTIES += \
    dalvik.vm.usejit=false \
    dalvik.vm.usejitprofiles=false \
    dalvik.vm.dex2oat-filter=speed \
    dalvik.vm.image-dex2oat-filter=speed \
    pm.dexopt.first-boot=verify \
    pm.dexopt.boot-after-ota=verify \
    pm.dexopt.install=speed \
    pm.dexopt.install-fast=speed \
    pm.dexopt.install-bulk=speed \
    pm.dexopt.bg-dexopt=speed \
    pm.dexopt.cmdline=speed \
    pm.dexopt.shared=speed

PRODUCT_PRODUCT_PROPERTIES += \
    ro.surface_flinger.supports_background_blur=0 \
    ro.sf.blurs_are_expensive=1 \
    persist.sysui.disableblur=true \
    ro.launcher.depth.widget=false \
    debug.sf.nobootanimation=1

PRODUCT_PACKAGES += Launcher3QuickStepGo kernarium_ui_defaults_script
PRODUCT_PACKAGES_EXCLUDE += Launcher3QuickStep Launcher3 Trebuchet
