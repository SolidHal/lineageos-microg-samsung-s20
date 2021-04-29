multidisabler is only needed for recovery auto-restore and wsm on s20 as long as magisk is used. 

need the wsm or bluetooth? fix for s20 from multidiabler for bluetooth to work. 

either modify the script to be configurable for encryption, or build these fixes into the kernel?

- twrp: https://forum.xda-developers.com/t/recovery-unofficial-twrp-for-galaxy-s20-series-snapdragon.4157901/

lineage-17.1 rom https://forum.xda-developers.com/t/rom-unofficial-s20-s20u-120hz-lineageos-17-1.4188495/


Build rom from scratch:
follow: https://wiki.lineageos.org/devices/sargo/build
up to breakfast

run:
```
source build/envsetup.sh
breakfast x1q
```
wait for that to complete, then modify `.repo/local_manifests/roomservice.xml` to be
```
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <project name="SolidHal/android_device_samsung_x1q" path="device/samsung/x1q" remote="github" revision="lineage-17.1" />
  <project name="SolidHal/android_device_samsung_sm8250-common" path="device/samsung/sm8250-common" remote="github" revision="lineage-17.1" />
  <project name="LineageOS/android_device_samsung_slsi_sepolicy" path="device/samsung_slsi/sepolicy" remote="github" />
  <project name="LineageOS/android_hardware_samsung" path="hardware/samsung" remote="github" />
	<project name="SolidHal/android_kernel_samsung_sm8250" path="kernel/samsung/sm8250" remote="github" revision="lineage-17.1-vendors-2.1" />
</manifest>
```

run:
```
repo sync --force-sync
```

now to get the proprietary files. :TODO: do we actually need any?

```
cd device/samsung/x1q/
./extrace-files.sh
```

magisk:
https://topjohnwu.github.io/Magisk/install.html#samsung-system-as-root
- get bluetooth fixes so pairing is remembered
- fdroid privileged extension
- aurora store

twrp: 
https://forum.xda-developers.com/t/recovery-unofficial-twrp-for-galaxy-s20-series-snapdragon.4157901/
Download & Guide:
1. Unlock your bootloader and disable AVB from here
2. Download S20: x1q, S20+: y2q or S20 Ultra z3q.
3. Reboot to download mode
4. Put the TWRP TAR for your device with Odin in the AP slot and click start.
5. Reboot to recovery via recovery key combo.
6. Disable encryption:
- Flash multidisabler-samsung-3.x.zip.​

Disable AVB:
https://forum.xda-developers.com/t/how-to-exynos-snapdragon-root-s20-series-and-upgrade-firmware.4079353/

get disable_vbmeta.tar
flash to AP using odin
wipe data

TODO: need sig spoofing in rom

Rough steps:
1) unlock bootloader
2) flash oneUI2.1 version, I am using G981U1UEU1ATG2
2) flash disable_vbmeta.tar
3) flash twrp, boot twrp
4) take boot.img from the lineageos.zip and feed it to magisk
5) wipe data/cache, flash multidisabler, lineage in twrp
6) boot, install magisk app


6) follow long magisk process here, making sure to put disable_vbmeta in the userdata slot : https://topjohnwu.github.io/Magisk/install.html#samsung-system-as-root
7) you now should effectively have stock firmware + magisk
8) 


## Build lineage
```
git checkout https://github.com/lineageos4microg/docker-lineage-cicd.git
cd docker-lineage-cicd
docker build --tag solidhal/docker-lineage-cicd .
```
