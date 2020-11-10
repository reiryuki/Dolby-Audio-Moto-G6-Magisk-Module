# Dolby Audio Moto G6 Magisk Module

## Descriptions
- An EQ ported from Motorola G6 (ali)
- Doesn't support dynamic partitions
- Doesn't support USB type C wired
- Spoofing product model/brand/device/manufacturer, may break some system apps.

## Requirements
- Android 8.1, 9, 10, 11 (Need test for Android 8.0)
- 32 bit or 64 bit platform
- Magisk Installed

## Installation Guide
- Remove another Dolby module
- Reboot
- Install via Magisk Manager only
- Reboot
- Set Dolby Audio as default EQ if you have more than one EQ

## Optional
- If using multiple audio mods, use one of these bellow, don't use both:
  - AML 4.0 supported
  - ACDB supported (Android 10 and bellow only for now)
- You can rename dax-default extension to use more bass enhancer boost. See /data/adb/modules_update/DolbyAudio/system/vendor/etc/dolby/

## Troubleshooting
- If Dolby force close, just reinstall again.
- Make sure manifest.xml is patched correctly.
- Use Audio Compatibility Patch if you encounter processing problem.
- If SE patch still fail even added to sepolicy.rule, then add `setenforce 0` to the top of service.sh. Give logcat before for fix.
- If you have some issues, like ringtones, alarm tones doesn't work, or calls opposite person doesn't hear, [do this fix.](https://t.me/audioryukimods/543)

## Attention!
- Reporting anything without sending full logcats and install process logs is ignored!
https://play.google.com/store/apps/details?id=com.dp.logcatapp
- Send run also:
  - `su`
  - `dumpsys media.audio_flinger`

## Credits
- @guitardedhero for daxService.apk base


