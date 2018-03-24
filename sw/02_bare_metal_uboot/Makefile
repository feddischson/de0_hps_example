TARGET 				:= bare_metal_example
SOC_ROOT 			:= ../../soc
QSYS_HEADERS 		:= ${SOC_ROOT}/qsys_headers
FPGARBF 			:= ${SOC_ROOT}/DE0_HPS_Example.rbf
PRELOADER_DIR 		:= preloader
OBJDIR 				:= obj
SDCARD 				:= sdcard.img
PRELOADER 			:= $(PRELOADER_DIR)/preloader-mkpimage.bin
UBOOTIMAGE 			:= u-boot.img
UBOOT 				:= $(PRELOADER_DIR)/uboot-socfpga/${UBOOTIMAGE}
ELF 				:= $(TARGET).axf
BIN 				:= $(TARGET).bin
BINMKIMAGE 			:= $(TARGET)_mkimage.bin
BOOTTXT 			:= boot.txt
BOOTSCR 			:= "u-boot.scr"
APP_LOADADDR 		:= 0x00100000
APP_ENTRYPOINT  	:= 0x00100000

# must be a multiple of 63 to make mcopy happy
# is multiplied by 512 (sector size)
SDCARD_SIZE 		:= 64512


# Cross-compilation setup
CROSS_COMPILE 		:= arm-altera-eabi-
CC 					:= $(CROSS_COMPILE)gcc
LD 					:= $(CROSS_COMPILE)g++
NM 					:= $(CROSS_COMPILE)nm
OD 					:= $(CROSS_COMPILE)objdump
OBJCOPY 			:= $(CROSS_COMPILE)objcopy
AS 					:= $(CROSS_COMPILE)as


# Further tools
BSP_GENERATE 		:= bsp-generate-files 
TRUNCATE 			:= truncate
DD 					:= dd
MCOPY 				:= mcopy
MKIMAGE 			:= mkimage
MKFS 				:= /usr/sbin/mkfs.vfat
FDISK 				:= /sbin/fdisk -b 512


# The source directory of the hwlib within the SOC-EDS
HWLIB_ROOT 			:= $(SOCEDS_DEST_ROOT)/ip/altera/hps/altera_hps/hwlib
HWLIB_DIR 			:= ./hwlib

# This board has a cyclone-V
DEVICE_FAMILY 		:= soc_cv_av


LINKER_SCRIPT 		:= cycloneV-dk-ram-hosted.ld
MULTILIBFLAGS 		:= -mfloat-abi=softfp -mtune=cortex-a9 -mcpu=cortex-a9 -march=armv7-a
ASFLAGS 			:=  -march=armv7-a -mcpu=cortex-a9
CFLAGS 				:= $(MULTILIBFLAGS) -g -O0 -Werror -Wall \
							-fdata-sections -ffunction-sections \
						  -I $(HWLIB_DIR)/include \
						  -I $(HWLIB_DIR)/include/soc_cv_av\
						  -D$(DEVICE_FAMILY) \
						  -DPRINTF_UART


HWLIB_SRC 		:=	$(HWLIB_DIR)/src/utils/alt_p2uart.c \
					$(HWLIB_DIR)/src/utils/alt_printf.c \
					$(HWLIB_DIR)/src/hwmgr/soc_cv_av/alt_system_manager.c \
					$(HWLIB_DIR)/src/hwmgr/soc_cv_av/alt_sdram.c \
					$(HWLIB_DIR)/src/hwmgr/soc_cv_av/alt_reset_manager.c \
					$(HWLIB_DIR)/src/hwmgr/soc_cv_av/alt_fpga_manager.c \
					$(HWLIB_DIR)/src/hwmgr/soc_cv_av/alt_ecc.c \
					$(HWLIB_DIR)/src/hwmgr/soc_cv_av/alt_clock_manager.c \
					$(HWLIB_DIR)/src/hwmgr/soc_cv_av/alt_bridge_manager.c \
					$(HWLIB_DIR)/src/hwmgr/soc_cv_av/alt_bridge_f2s_gnu.s \
					$(HWLIB_DIR)/src/hwmgr/alt_watchdog.c \
					$(HWLIB_DIR)/src/hwmgr/alt_timers.c \
					$(HWLIB_DIR)/src/hwmgr/alt_spi.c \
					$(HWLIB_DIR)/src/hwmgr/alt_sdmmc.c \
					$(HWLIB_DIR)/src/hwmgr/alt_qspi.c \
					$(HWLIB_DIR)/src/hwmgr/alt_nand.c \
					$(HWLIB_DIR)/src/hwmgr/alt_mmu.c \
					$(HWLIB_DIR)/src/hwmgr/alt_interrupt.c \
					$(HWLIB_DIR)/src/hwmgr/alt_i2c.c \
					$(HWLIB_DIR)/src/hwmgr/alt_globaltmr.c \
					$(HWLIB_DIR)/src/hwmgr/alt_generalpurpose_io.c \
					$(HWLIB_DIR)/src/hwmgr/alt_dma_program.c \
					$(HWLIB_DIR)/src/hwmgr/alt_dma.c \
					$(HWLIB_DIR)/src/hwmgr/alt_can.c \
					$(HWLIB_DIR)/src/hwmgr/alt_cache.c \
					$(HWLIB_DIR)/src/hwmgr/alt_address_space.c \
					$(HWLIB_DIR)/src/hwmgr/alt_16550_uart.c

SRC 			:= $(HWLIB_SRC)\
				  ./bare_metal_example.c

OBJS := $(patsubst %.c,%.o,$(SRC)) 
OBJS := $(patsubst %.s,%.o,$(OBJS)) 
OBJS := $(patsubst %.o,$(OBJDIR)/%.o,$(OBJS)) 

define FDISK_CMD
n
p
2
2048
+1M
n
p
1
4096
+5M
t
2
a2
t
1
c
w
q
endef
export FDISK_CMD

.PHONY: all
all: $(SDCARD)


$(HWLIB_SRC):
	$(shell cp -r $(HWLIB_ROOT) $(HWLIB_DIR) )
	$(shell mkdir -p $(OBJDIR)/$(HWLIB_DIR)/src/utils)
	$(shell mkdir -p $(OBJDIR)/$(HWLIB_DIR)/src/hwmgr/soc_cv_av)

$(BINMKIMAGE): $(BIN) Makefile
	$(MKIMAGE) -A arm -O u-boot  -T standalone -C none -a ${APP_LOADADDR} -e ${APP_ENTRYPOINT} -n bare-metal-example  -d $(BIN) $(BINMKIMAGE)

$(BIN): $(ELF)
	$(OBJCOPY) -O binary $(ELF) $@

$(ELF): $(OBJS)
	$(LD) -T$(LINKER_SCRIPT) $(MULTILIBFLAGS) $(OBJS) -Xlinker -Map=${TARGET}.map -o $@

$(OBJDIR)/%.o : %.c Makefile
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIR)/%.o: %.s Makefile
	$(AS) $(ASFLAGS) -c $< -o $@

${BOOTSCR}: ${BOOTTXT}
	mkimage -A arm -T script -O linux -d ${BOOTTXT} ${BOOTSCR}

.PHONY: uboot
uboot: $(UBOOT)

$(UBOOT): $(PRELOADER)
	make -C $(PRELOADER_DIR) uboot

.PHONY: preloader
preloader: $(PRELOADER)

$(PRELOADER): $(PRELOADER_DIR)/settings.bsp
	$(BSP_GENERATE)--settings $(PRELOADER_DIR)/settings.bsp --bsp-dir $(PRELOADER_DIR)
	make -C $(PRELOADER_DIR)



$(SDCARD): $(PRELOADER) $(BIN) $(UBOOT) $(BOOTSCR)

	echo $(OBJS)

	#
	# Create the three parts (MBR, FSB and FAT) 
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
	$(MCOPY) -i $(SDCARD).03.tmp $(BIN) 		::$(BIN)
	$(MCOPY) -i $(SDCARD).03.tmp $(UBOOT) 	    ::$(UBOOTIMAGE)
	$(MCOPY) -i $(SDCARD).03.tmp $(BOOTSCR) 	::$(BOOTSCR)
	$(MCOPY) -i $(SDCARD).03.tmp $(FPGARBF) 	::socfpga.rbf

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
	rm -rf $(TARGET) *.axf *.bin \
	  $(HWLIB_DIR) \
	  $(OBJDIR) \
	  $(SDCARD) \
	  $(BOOTSCR) \
	  $(PRELOADER_DIR)/generated \
	  $(PRELOADER_DIR)/uboot-socfpga \
	  $(PRELOADER_DIR)/*.ds \
	  $(PRELOADER_DIR)/*.bin  \
	  $(PRELOADER_DIR)/Makefile

