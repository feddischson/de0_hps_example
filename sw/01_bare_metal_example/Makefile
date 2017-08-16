TARGET 				:= bare_metal_example
QSYS_HEADERS 		:= ../../soc/qsys_headers
MULTILIBFLAGS 		:= -mfloat-abi=softfp -mtune=cortex-a9 -mcpu=cortex-a9 -march=armv7-a
CFLAGS 				:= $(MULTILIBFLAGS) -g -O0 -Werror -Wall -Wstrict-prototypes
SRC 				:= bare_metal_example.c
PRELOADER_DIR 		:= preloader
PRELOADER 			:= $(PRELOADER_DIR)/preloader-mkpimage.bin
SDCARD 				:= sdcard.img
LINKER_SCRIPT 		:= cycloneV-dk-oc-ram-hosted.ld
OBJCOPY 			:= arm-altera-eabi-objcopy
ELF 				:= $(TARGET).axf
BIN 				:= $(TARGET).bin

# must be a multiple of 63 to make mcopy happy
# is multiplied by 512 (sector size)
SDCARD_SIZE 		:= 64512

CROSS_COMPILE 		:= arm-altera-eabi-
CC 					:= $(CROSS_COMPILE)gcc
LD 					:= $(CROSS_COMPILE)g++
NM 					:= $(CROSS_COMPILE)nm
OD 					:= $(CROSS_COMPILE)objdump
BSP_GENERATE 		:= bsp-generate-files 
TRUNCATE 			:= truncate
DD 					:= dd
MKFS 				:= /usr/sbin/mkfs.vfat
FDISK 				:= /sbin/fdisk -b 512
MCOPY 				:= mcopy

define FDISK_CMD
n
p
1
2048
+1M
n
p
2
4096

t
1
2a
t
2
c
w
q
endef
export FDISK_CMD


.PHONY: all
all: $(SDCARD)

build: $(BIN)

$(BIN): $(ELF)
	$(OBJCOPY) -O binary $(ELF) $@

$(ELF): $(TARGET).o
	$(LD) -T$(LINKER_SCRIPT) $(MULTILIBFLAGS) $(TARGET).o -o $@

%.o : %.c
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: preloader
preloader: $(PRELOADER)

$(PRELOADER): $(PRELOADER_DIR)/settings.bsp
	$(BSP_GENERATE)--settings $(PRELOADER_DIR)/settings.bsp --bsp-dir $(PRELOADER_DIR)
	make -C $(PRELOADER_DIR)



$(SDCARD): $(PRELOADER) $(BIN)
	#
	# Create the three partitions (MBR, FSB and FAT) 
	# individually and concatenate them afterwards:
	#

	# MBR
	$(DD) if=/dev/zero of=$(SDCARD).01.tmp bs=512 count=2048

	# Preloader partition
	cp $(PRELOADER) $(SDCARD).02.tmp
	$(TRUNCATE) --size=1M $(SDCARD).02.tmp

	# FAT partition
	$(DD) if=/dev/zero of=$(SDCARD).03.tmp bs=512 count=$(SDCARD_SIZE)
	$(MKFS) -v $(SDCARD).03.tmp
	$(MCOPY) -i $(SDCARD).03.tmp $(BIN) ::$(BIN)

	cat $(SDCARD).01.tmp  > $(SDCARD).tmp
	cat $(SDCARD).02.tmp >> $(SDCARD).tmp
	cat $(SDCARD).03.tmp >> $(SDCARD).tmp

	echo "$$FDISK_CMD"  | $(FDISK) $(SDCARD).tmp
	mv $(SDCARD).tmp $(SDCARD)

	rm $(SDCARD).01.tmp
	rm $(SDCARD).02.tmp
	rm $(SDCARD).03.tmp



.PHONY: clean
clean:
	rm -rf $(TARGET) *.a *.o \
	  $(PRELOADER_DIR)/generated \
	  $(PRELOADER_DIR)/uboot-socfpga \
	  $(PRELOADER_DIR)/*.ds \
	  $(PRELOADER_DIR)/*.bin  \
	  $(PRELOADER_DIR)/Makefile

