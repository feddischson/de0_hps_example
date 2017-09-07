
Synopsis
==========
This example design is just used for playing around with the Angstrom Linux distribution.

Linux
=======

This example SOC system can be used together with the 
[Angstrom Linux Distribution)](https://github.com/Angstrom-distribution) (tested with the 2016 branch).


Integration
------------------

1. Run `make all` to create all required targets.
2. Get and prepare the Angstrom image as described [here](https://github.com/Angstrom-distribution/angstrom-manifest)
3. Patch or adapt u-boot that u-boot loads the FPGA bitstream, for example with
```patch

diff --git a/include/configs/socfpga_de0_nano_soc.h b/include/configs/socfpga_de0_nano_soc.h
index fdddfa3cd2..59859c409a 100644
--- a/include/configs/socfpga_de0_nano_soc.h
+++ b/include/configs/socfpga_de0_nano_soc.h
@@ -21,7 +21,7 @@
 #define CONFIG_BOOTDELAY       3
 #define CONFIG_BOOTFILE                "fitImage"
 #define CONFIG_BOOTARGS                "console=ttyS0," __stringify(CONFIG_BAUDRATE)
-#define CONFIG_BOOTCOMMAND     "run mmcload; run mmcboot"
+#define CONFIG_BOOTCOMMAND     "run fpgaload; run mmcload; run mmcboot"
 #define CONFIG_LOADADDR                0x01000000
 #define CONFIG_SYS_LOAD_ADDR   CONFIG_LOADADDR

@@ -39,6 +39,10 @@
        "ramboot=setenv bootargs " CONFIG_BOOTARGS ";" \
                "bootm ${loadaddr} - ${fdt_addr}\0" \
        "bootimage=zImage\0" \
+   "ethaddr=C0:B1:3D:88:78:89\0" \
+   "ipaddr=192.168.222.55\0" \
+   "serverip=192.168.222.11\0" \
+   "fpgaimage=socfpga.rbf\0" \
        "fdt_addr=100\0" \
        "fdtimage=socfpga.dtb\0" \
        "bootm ${loadaddr} - ${fdt_addr}\0" \
@@ -46,6 +50,11 @@
        "mmcboot=setenv bootargs " CONFIG_BOOTARGS \
                " root=${mmcroot} rw rootwait;" \
                "bootz ${loadaddr} - ${fdt_addr}\0" \
+   "fpgaload=mmc rescan;" \
+      "load mmc 0:1 ${loadaddr} ${fpgaimage};" \
+      "bridge disable;" \
+      "fpga load 0 ${loadaddr} ${filesize};" \
+      "bridge enable\0" \
        "mmcload=mmc rescan;" \
                "load mmc 0:1 ${loadaddr} ${bootimage};" \
                "load mmc 0:1 ${fdt_addr} ${fdtimage}\0" \

```
4. Flash the sd-card and copy + rename the *.dtb and *.rbf file to the sd-card (as socfpga.dtb and socfpga.rbf)


Device-Tree-Source
-------------------

There exists several ways to get a device tree source. In this example, 
the corresponding dts files from the kernel's dts folder are copied and 
slightly adapted as also mentioned in [1].

The toplevel `DE0_HPS_Example.dts` can be used to configure and extend
the base file (`socfpga_cyclone5.dtsi`), which means that the
`DE0_HPS_Example.dts` should match the SOC configuration (`DE0_HPS_Example.qsys`) including the FPGA part.



LEDs
---------
There exists one green LED which is connected to the HPS via GPIO, 
which is connected to pin GPIO53 (A20).
According to [2,Page 3157] this is mapped to GPIO-1, index 24.

This LED can be controlled via `/sys/class/leds/hps_led0`, for example
```
echo mmc0 > /sys/class/leds/hps_led0/trigger
```
enables mmc0 access activity to be shown on the HPS LED.


The FPGA LEDs can be controlled in a similar way via `/sys/class/leds/fpga_led*`.

More details can be found in [4].


Switch-Buttons
---------------
The four switch buttons are accessed via GPIO on the FPGA-side.
This appears within linux under `/sys/class/gpio/gpiochip508` where 508 is the first gpio index.
The four buttons can be exported via
```
echo 508 > /sys/class/gpio/export
echo 509 > /sys/class/gpio/export
echo 510 > /sys/class/gpio/export
echo 511 > /sys/class/gpio/export
```
and then controlled via
```
/sys/class/gpio/gpio508/
/sys/class/gpio/gpio509/
/sys/class/gpio/gpio510/
/sys/class/gpio/gpio511/
```

More details can be found in [3].

HPS-Pushbutton (KEY-2)
----------------
The HPS pushbutton pin connected to pin GPIO54, which is mapped GPIO-1, index 25.
This button can be accessed via
```
echo 465 > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio465/direction
cat /sys/class/gpio/gpio465/value
```

FPGA-Pushbuttons (KEY-0 and KEY-1(
----------------
The twp pushbuttons are accessed via GPIO on the FPGA-side.
This appears within linux under `/sys/class/gpio/gpiochip508` where 498 is the first gpio index.
The four buttons can be exported via
```
echo 498 > /sys/class/gpio/export
echo 499 > /sys/class/gpio/export
```
and then controlled via
```
/sys/class/gpio/gpio498/
/sys/class/gpio/gpio499/
```



LTC-Connector
---------------
The LTC mux (TS3A5018) select pin is mapped to GPIO-1, index 11.
Do
```
echo 451 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio451/direction
```
to map this pin to user-space (440 is the base index of GPIO-1 and 440+11 = 451).
*Setting/clearing this pin haven't shown any result, yet.
The schematic shows a pull-up resistor, but the pin is somehow pulled down.*

References
=====================

[1] https://lists.rocketboards.org/pipermail/rfi/2016-June/003427.html



[2] Cyclone V Hard Processor System Technical Reference Manual; Altera; 2016.10.28
    https://www.altera.com/content/dam/altera-www/global/en_US/pdfs/literature/hb/cyclone-v/cv_5v4.pdf

[3] GPIO kernel documentation [https://www.kernel.org/doc/Documentation/gpio/sysfs.txt](https://www.kernel.org/doc/Documentation/gpio/sysfs.txt)

[4] LED kernel documentation [https://www.kernel.org/doc/Documentation/leds/leds-class.txt](https://www.kernel.org/doc/Documentation/leds/leds-class.txt)

[5] eLinux wiki about linux dts [http://elinux.org/Device_Tree_Usage](http://elinux.org/Device_Tree_Usage)
