# Samsung S20 (snapdragon) LineageOS with MicroG and Magisk

## Requirements
- adb from the android platform tools package.
- odin 3.14.4 - can be found around xda

### Key combos

power + volume down + volume up
  - when device is plugged in to a computer and powered off, this will take you to download mode
power + volume up
  - when device is powered off, and these are held during bootup this will take you to recovery
  - ignore the message about verified boot asking you to press the side button, and keep holding until you get into recovery

## Install lineageos with microg

### Prepare your device
1) unlock your bootloader. There are guides available on XDA.
2) flash a oneUI2.1 version. This is required for bug free functionality. I am using G981U1UEU1ATG2
  - IMPORTANT: when downgrading/upgrading stock roms make sure you also flash disable_vbmeta.tar in the USERDATA slot instead of the AP slot!
   - When looking on rom sites, you can tell the oneUI version from the 4th to last letter
   - A ex: `ATG2` is 2.1
   - B ex: `BS3F` is 2.5
   - C ex: `CTG7` is 3.0
   - D ex: `DLG4` is 3.1
3) flash resources/disable_vbmeta.tar
   - this is just flashing a blank vbmeta image, which disables vbmeta
   - when flashing `disable_vbmets.tar` alone, load it into the AP slot in odin. upon reboot wipe data
   
### Setup recovery
1) flash lineage_recovery.tar or twrp. You have some options here:
   a) The most recent tar can be found here: https://github.com/SolidHal/lineageos-microg-samsung-s20/releases
   b) (if you know what you are doing, or want to learn) you can go to the `Build lineageos with microg` section and come back here after you are done to flash your own recovery.img
   c) (easiest) or you can flash twrp.
     - Download link: https://forum.xda-developers.com/t/recovery-unofficial-twrp-for-galaxy-s20-series-snapdragon.4157901/
     - For lineage 17.1 we want the `Q` release
     - For lineage 18.1 we want the `R` release
2) Whichever option you choose for your recovery image, you must first flash twrp so we can run the multidisabler. Unfortunately the lineage recovery doesn't support the multidisabler.
  - Enter download mode and flash twrp in the ap slot using odin.
  - as soon as the screen goes black, press and hold power+volume up
  - DONT LET GO UNTIL YOU GET INTO RECOVERY. If it takes longer than 5 minutes, try again.
  - once in recovery, wipe data/cache and factory reset. 
3) Flash multidisabler
  - NOTE: the usual samsung multidisabler disables data encryption this means that twrp can read/write to your data partition making flashing a little easier *BUT* it also means you user data is completely unencrypted. This is a huge security/privacy risk on a mobile device and should not be done unless extremely necessary.
  - `multidisabler-samsung-keep-encryption` is a fork of the multidisabler with the step that disables encryption removed.
  - grab the most recent release from here: https://github.com/SolidHal/multidisabler-samsung-keep-encryption/releases
  - flash `multidisabler-samsung-*-keep_encrypt.zip` using twrp either by loading it on your sd card, or by using `adb sideload` in the advanced menu and running
    - adb sideload multidisabler-samsung-*-keep_encrypt.zip on your computer
4) Flash your final recovery
  - if you want to keep twrp, skip this step
  - if you want to use lineage recovery, boot your device in download mode again and flash the lineage recover tar in the `AP` slot
  - remember to hold volume up + power as soon as the screen goes black, and don't let go until you see the recovery screen
  
### Finally flash the rom
1) Flash the lineage rom
  - boot into recovery if you aren't already in it
  - adb sideload the rom like so:
    - `adb sideload lineage-*.zip`
  - or the version with magisk pre-installed:
    - `adb sideload lineage-17.1-magisk-*.zip`
    - since magisk is pre-installed, the lineage recovery will complain about the signature not being correct.
      just choose yes and continue when it asks


## Build lineageos with microg and magisk

### Prepare build encironment
First build the docker image
```
git checkout https://github.com/lineageos4microg/docker-lineage-cicd.git
cd docker-lineage-cicd
docker build --tag solidhal/docker-lineage-cicd .
```

### Run build
Now head back to this checkout, and run the build script
This will take quite some time, and use ~200GB of disk space.
`build_x1q.sh` can be modified to not include microg, or signature spoofing if you would prefer.
```
cd build
./build_x1q.sh
```
### Prepare recovery image
Once the build is complete, you have to package up your recovery.img in a way odin likes:
```
cd zips
cp *recovery.img recovery.img
tar -H ustar -c recovery.img > lineage_recovery.tar
```
and your rom is the `zips/lineage-*.zip` file

Now go back up and complete the install instructions. You need lineageos running to run the following magisk steps. Come back down here once you are booting.

### Install Magisk

Now that you have your own lineageos image installed, download the magisk apk from https://github.com/topjohnwu/Magisk/releases and install it.
Unzip the `lineage-*.zip` on your computer, and copy the `boot.img` onto your phone either using and sdcard or `adb push`
Open the magisk app and install it to your `boot.img` 
Grab the `magisk_patched-<random_characters>.img` from your Downloads and get it back on your computer
Rename it to `boot.img`, and copy it into your rom file `lineage-*.zip` overwriting the old `boot.img`
Reboot into recovery and `adb sideload` the `lineage-*.zip` again.
Since magisk is now installed on the boot.img, the lineage recovery will complain about the signature not being correct.
just choose yes and continue when it asks
Once it is complete, you are done!


## Known issues:
- padding on the status bar for the rounded corners is incorrect.
This can be fixed at runtime using:
```
adb shell settings put secure sysui_rounded_content_padding 22
```

- finger print enrollment is touchy
Method that always succeeds:
1) press next
2) quickly tap fingerprint sensor
3) you should now see the `Lift, then touch again` screen
4) wait 1 second
5) register fingerprint like usual


TODO: 
- sign the magisk builds so recovery doesn't complain
- enforce signature checking in recovery, must set PRODUCT_EXTRA_RECOVERY_KEYS like we set PRODUCT_DEFAULT_DEV_CERTIFICATE in the build
  - https://source.android.com/devices/tech/ota/sign_builds#signatures-sideloading

## Debug booting
if your device won't boot, and you can't get adb to work in the eng builds try
looking at the logs in:
```
/proc/last_kmsg
/sys/fs/pstore/
```

## debug selinux and sepolicy
this post is a great intro: https://lineageos.org/engineering/HowTo-SELinux/

`avc:` denials can be found in logcat and dmesg

you can pull the running policy by doing:
```
adb shell cat /sys/fs/selinux/policy > policy
```

and get some suggestions for policies to add from:
```
audit2allow -i dmesg.txt -p policy
```


## Rough steps:
keeping these around for now...
1) unlock bootloader
2) flash oneUI2.1 version, I am using G981U1UEU1ATG2
2) flash disable_vbmeta.tar
3) flash lineage_recovery.tar
4) take boot.img from the lineageos.zip and feed it to magisk
5) wipe data/cache, flash multidisabler, lineage in twrp
6) boot, install magisk app

# Thanks
 - To the member of the XDA fourms that are unlocking the snapdragon s20
 - To @jesec who got the s20 supported for lineage 17.1
 - To jimbo77 on xda who had some nice lineage builds for the s20, looking at their source got me pointed in the right direction
