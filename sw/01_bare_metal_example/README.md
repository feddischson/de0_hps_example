
Content
====================
This example builds a pre-loader, a simple `hello-world` application and puts all together on an SD-card image.



Further Information
--------------------
Some good information can be found here: http://www.alterawiki.com/wiki/SoCEDSGettingStarted, where a 
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
