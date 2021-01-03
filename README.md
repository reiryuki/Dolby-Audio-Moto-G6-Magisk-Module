# Dolby Audio Moto G6 Magisk Module

## Descriptions
- An EQ ported from Motorola G6 (ali)
- Doesn't support dynamic partitions
- Spoofing product model/brand/device/manufacturer, may break some system apps.

## Requirements
- Android 8.0 (not tested), 8.1, 9, 10, or 11
- Magisk Installed

## Installation Guide
- Remove another Dolby module
- Reboot
- Install via Magisk Manager only
- Reboot

## Optional
- If using multiple audio mods, use one of these bellow, don't use both:
  - AML 4.0 supported
  - ACDB supported (Android 10 and bellow only for now)
- If your ROM has Dolby in-built, or Dolby effects are not triggered, then you need to enable Dolby data clean-up for the first time. Run at Terminal Emulator before flashing
  the module:

  `su`

  `setprop` `dolby.force.cleanup` `1`

  After that, flash/reflash the module.

- You can rename any dax-default extension to .xml to use more bass enhancer boost. See /data/adb/modules_update/DolbyAtmos/system/vendor/etc/dolby/. Rename another .xml to .mod. Delete /data/vendor/media/dax_sqlite3.db if there before reboot. 96 is a standard high bass.
- You can use black themed UI. To enable that, run at Terminal Emulator before flashing
  the module:

  `su`

  `setprop` `dolby.force.blackui` `1`

  After that, flash/reflash the module.

- You can disable your in-built Dirac audio FX if you sure it's conflicting with Dolby. Run at Terminal Emulator before flashing
  the module:

  `su`

  `setprop` `dolby.force.disable.dirac` `1`

  After that, flash/reflash the module.

- You can disable your in-built MI Sound FX if you sure it's conflicting with Dolby. Run at Terminal Emulator before flashing
  the module:

  `su`

  `setprop` `dolby.force.disable.misoundfx` `1`

  After that, flash/reflash the module.


## Troubleshooting
- If SE policy patch doesn't work for your device, send logcats to dev, then try using force permissive method.
  Run at Terminal Emulator before flash:
  - `su`
  - `setprop dolby.force.permissive 1`
- If Dolby force close, just reinstall again.
- Make sure manifest.xml is patched correctly.
- Use Audio Compatibility Patch if you encounter processing problem.
- If you have some issues, like ringtones, alarm tones doesn't work, or calls opposite person doesn't hear, [do this fix.](https://t.me/audioryukimods/543)

## Attention!
- Reporting anything without sending full logcats and install process logs is ignored!
https://play.google.com/store/apps/details?id=com.dp.logcatapp
- Send run also:
  - `su`
  - `dumpsys media.audio_flinger`

## Credits
- All people that helped and tested my modules
- @aip_x for modified black themed UI

## Telegram
- https://t.me/audioryukimods
- https://t.me/modsandco

## Donate
- https://www.paypal.me/reiryuki


