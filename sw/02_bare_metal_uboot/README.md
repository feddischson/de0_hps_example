
Synopsis
====================

This example is similar to `01_bare_metal_example`, but uses also u-boot as intermediate boot step.

The following boot-steps are done
  1) Reset
  2) BootROM: Loads the preloader from a sdcard partition of type `a2`
  3) Preloader: Loads u-boot
  4) U-Boot: Loads the bare-metal application `bare_metal_example.bin` from a FAT-partition into RAM at 0x00100000 and runs the application


Note: the image `bare_metal_example.bin` is extended with a header via mkimage.
This might be possible, but u-boot was not happy with that (give me a hint if you know how to get it working).


Preparation
===================
Run Intel's embedded shell: `${PATH_TO_INTEL_FLGA_LITE}/embedded/embedded_command_shell.sh
and ensure, that LC_ALL in the environment is cleared: `export LC_ALL=`
(this influences somehow uboot).


Build
===================
Run `make all` to create the sd-card image `sdcard.img`.

or use CMake via
```
mkdir build
cd build
cmake -DCMAKE_TOOLCHAIN_FILE=../toolchain-arm-altera-eabi.cmake ../
make
make sdcard
```


Installation
===================
Use `dd if=./sdcard.img of=/dev/SDX bs=1M && sync` to write the image on an SD-Card.
Replace `SDX` by the correct sd-card device.

