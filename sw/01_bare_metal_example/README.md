
Synopsis
====================
This example builds a pre-loader, a simple hello-world application and puts all together on an SD-card image.

The switches SW10 of the DE0-nano-SOC board must be configured as following:
 - 1: ON
 - 2: OFF
 - 3: ON
 - 4: OFF
 - 5: ON
 - 6: ON

The following boot-steps are done
  1) Reset
  2) BootROM: Loads the preloader from a sdcard partition of type `a2`
  3) Preloader: Loads the bare-metal application `bare_metal_example_mkimage.bin` from a FAT-partition into RAM at 0x00100000 and runs the application


Further Information
--------------------
Some good information can be found here: http://www.alterawiki.com/wiki/SoCEDSGettingStarted where a 
Python script can be downloaded: `create_hwlibs_project.py`.
This python script can also be used to create such a simple hello world, but it does not create a SD-Card image.


BSP-Editor
---------------
Use `bsp-editor --settings preloader/settings.bsp` to adapt the preloader.
In this configuration
  - booting rom SDMMC is set
  - the watchdog is disabled by the preloader
  - the file `bare_metal_example_mkimage.bin` is loaded from FAT-fs
  - debugging via serial out is enabled


Build
===================
Run `make all` to create the sd-card image `sdcard.img`.


Installation
===================
Use `dd if=./sdcard.img of=/dev/SDX bs=1M && sync` to write the image on an SD-Card.
Replace `SDX` by the correct sd-card device.

