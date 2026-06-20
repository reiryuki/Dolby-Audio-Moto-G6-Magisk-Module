# Dolby Audio Moto G6 Magisk Module

## DISCLAIMER
- Dolby apps and blobs are owned by Dolby™.
- The MIT license specified here is for the Magisk Module only, not for Dolby apps and blobs.

## Descriptions
- Equalizer sound effect ported from Motorola Moto G6 (ali) and integrated as a Magisk Module for all supported and rooted devices with Magisk
- Global type sound effect
- Conflicted with `vendor.dolby.hardware.dms@2.0-service`

## Sources
- https://dumps.tadiphone.dev/dumps/motorola/ali user-9-PPS29.118-11-aa435-release-keys
- libsqlite.so: https://dumps.tadiphone.dev/dumps/zte/p855a01 msmnile-user-11-RKQ1.201221.002-20211215.223102-release-keys
- DaxUI.apk: https://apkcombo.com/id/dolby-atmos/com.dolby.dax2appUI/download/apk
- system_black: https://t.me/viperatmos DolbyAtmos-moto-onepower-0.01-ACDB.zip
- Dolby codecs files: https://dumps.tadiphone.dev/dumps/motorola/sofiap_sprout sofiap_ao_eea-user-10-QPRS30.80-109-2-6-6e7cd-release-keys
- libhidlbase.so, libhidltransport.so, & libhwbinder.so: CrDroid ROM Android 13
- libutils.so: LineageOS 23 Android 16 BP2A.250605.031.A2 1758630651
- libmagiskpolicy.so: Magisk (stable) 30.7 (30700)

## Changelog

v9.4
- Support NoMount metamodule
- Resets module folders/files permissions at post-fs-data
- Move _uninstall.log to /data/adb/logs/
- Hides LunarisDolby.apk
- Removes conflicted weird modules

v9.3
- Update libmagiskpolicy.so from Magisk (stable) 30.7 (30700) (fixes selinux denials in KernelSU)
- Does not disable raw playback (You can use Audio Compatibility Patch Reborn Magisk Module instead)

v9.2
- Fix wrong target in latest KernelSU
- Improve detections

v9.1
- Fix wrong manifest.xml location patch target in latest Magisk version

v9.0
- Tidy up aml.sh
- Exclude \*audio\*effects\*haptic\*.xml
- Fix wrong file permissions in some ROMs

v8.9
- Fix ZN7android8String16aSEOS0 function not found in some ROMs
- Add libutils.so as system_support
- Abort installation if fail to mount mirror system

v8.8
- Fake Kitsune Mask detection
- Improve /odm and /my_product support detection

v8.7
- Fix script bug at installation for libsqlite.so detections
- Fix selinux denials

v8.6
- Modifies all blobs to fix conflict with in-built Dolby

v8.5
- Add Action button to clear apps caches
- Fix architecture detection in some weird ROMs
- Fix bug in uninstall.sh

## Screenshots
https://t.me/androidryukimodsdiscussions/610

## Requirements
- armeabi-v7a or arm64-v8a with armeabi-v7a support architecture
- 32 bit HIDL audio service
- Android 8 (SDK 26) and up
- Magisk or Kitsune Mask or KernelSU or Apatch installed (Recommended to use Magisk Delta/Kitsune Mask for systemless early init mount manifest.xml if your ROM is Read-Only https://t.me/ryukinotes/49)

## WARNING!!!
Possibility of bootloop or even softbrick or a service failure on Read-Only ROM if you don't use Magisk Delta/Kitsune Mask.

## Installation Guide & Download Link
- Recommended to use Magisk Delta/Kitsune Mask https://t.me/ryukinotes/49
- Remove any other else Dolby MAGISK MODULE with different name (no need to remove if it's the same name)
- Reboot
- If you are using KernelSU, you need to disable Unmount Modules by Default in KernelSU app settings and install https://github.com/KernelSU-Modules-Repo/meta-overlayfs or https://github.com/KernelSU-Modules-Repo/magic_mount_rs or https://github.com/KernelSU-Modules-Repo/hybrid_mount or https://github.com/maxsteeel/nomount first depending on ROM compatibility
- If you have Dolby in-built in your ROM, then you need to activate data.cleanup=1 at the first time install (READ Optionals bellow!)
- Install this module https://devuploads.com/g5f1vf7qdte6 via Magisk app or Kitsune Mask app or KernelSU app or Apatch app or Recovery if Magisk or Kitsune Mask installed
- Install AML Magisk Module https://t.me/ryukinotes/34 only if using any other else audio mod module
- Reboot
- If you are using KernelSU, you need to allow superuser list manually all package name listed in package.txt (and your home launcher app also) (enable show system apps) and reboot afterwards
- If you are using SUList, you need to allow list manually your home launcher app (enable show system apps) and reboot afterwards
- If you have sensors issue (fingerprint, proximity, gyroscope, etc), then READ Optionals bellow!

## Optionals
- https://t.me/ryukinotes/8
- Global: https://t.me/ryukinotes/35
- Stream: https://t.me/ryukinotes/52

## Troubleshootings
- https://t.me/ryukinotes/10
- https://t.me/ryukinotes/11
- Global: https://t.me/ryukinotes/34

## Support & Bug Report
- https://t.me/ryukinotes/54
- If you don't do above, issues will be closed immediately

## Credits and Contributors
- @HuskyDG
- https://t.me/viperatmos
- https://t.me/androidryukimodsdiscussions
- @HELLBOY017
- You can contribute ideas about this Magisk Module here: https://t.me/androidappsportdevelopment

## Sponsors
https://t.me/ryukinotes/25


