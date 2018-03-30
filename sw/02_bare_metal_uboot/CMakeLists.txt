
cmake_minimum_required(VERSION 3.6)
set( PROJ_NAME bare_metal_example )
project( ${PROJ_NAME} C CXX ASM)
set(CMAKE_CXX_STANDARD 11)


##
#   Names and path variables
##
set( SOC_RBF_NAME         DE0_HPS_Example.rbf )
set( SOC_CDF_NAME         DE0_HPS_Example.cdf )

set( FPGARBF_PATH         ${CMAKE_CURRENT_SOURCE_DIR}/../../soc/${SOC_RBF_NAME}   )
set( CDF_PATH             ${CMAKE_CURRENT_SOURCE_DIR}/../../soc/${SOC_CDF_NAME}   )
set( LINKER_SCRIPT        cycloneV-dk-ram-hosted.ld )
set( TARGET_AXF_NAME      ${PROJ_NAME}.axf    )
set( UBOOT_NAME           u-boot.img          )
set( TARGET_BIN_NAME      ${PROJ_NAME}.bin    )
set( TARGET_MAP_NAME      ${PROJ_NAME}.map    )
set( BOOT_SCR_NAME        u-boot.scr          )
set( SDCARD_NAME          sdcard.img          )

set( PRELOADER_DIR        ${CMAKE_CURRENT_BINARY_DIR}/preloader          )
set( BOOTTXT              ${CMAKE_CURRENT_SOURCE_DIR}/boot.txt           )

set( TARGET_BIN_PATH      ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_BIN_NAME} )
set( TARGET_AXF_PATH      ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_AXF_NAME} )
set( BOOT_SCR_PATH        ${CMAKE_CURRENT_BINARY_DIR}/${BOOT_SCR_NAME}   )
set( UBOOT_PATH           ${PRELOADER_DIR}/uboot-socfpga/${UBOOT_NAME}   )

# Size of the SD-Card image:
# must be a multiple of 63 to make mcopy happy
# is multiplied by 512 (sector size)
set( SDCARD_SIZE 64512 )

# Required by the intel/altera's hwlib
add_definitions(-Dsoc_cv_av)

# Required to enable printing via UART (see alt_printf.h)
add_definitions(-DPRINTF_UART)

add_definitions(-DALT_INT_PROVISION_VECTOR_SUPPORT=0)

# Compiler, assembler and linker setup
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} \
                            -T${LINKER_SCRIPT}  \
                            -Xlinker -Map=${TARGET_MAP_NAME} \
                            -Xlinker --gc-sections" )

set( CMAKE_C_FLAGS  "-mfloat-abi=softfp -mtune=cortex-a9 -mcpu=cortex-a9 -march=armv7-a -mfpu=neon \
                     -Wall -fdata-sections -ffunction-sections \
                     -g -O0" )
set( ASFLAGS        "-mfloat-abi=softfp -mcpu=cortex-a9 -march=armv7-a -mfpu=neon" )


# Copy hwlib
if(DEFINED ENV{SOCEDS_DEST_ROOT})
  message( "Staging hwlib from $ENV{SOCEDS_DEST_ROOT}/ip/altera/hps/altera_hps/hwlib ")
  file(COPY $ENV{SOCEDS_DEST_ROOT}/ip/altera/hps/altera_hps/hwlib  DESTINATION
    ${CMAKE_CURRENT_BINARY_DIR}/src/ )
else()
  message( FATAL_ERROR "SOCDEFS_DEST_ROOT not found in environment, please source embedded_command_shell.sh")
endif()


##
#
#  Source files
#
#
set( SOURCE_FILES
  ${CMAKE_CURRENT_BINARY_DIR}/src/hwlib/src/utils/alt_p2uart.c
  ${CMAKE_CURRENT_BINARY_DIR}/src/hwlib/src/hwmgr/alt_16550_uart.c
  ${CMAKE_CURRENT_BINARY_DIR}/src/hwlib/src/utils/alt_printf.c
  ${CMAKE_CURRENT_BINARY_DIR}/src/hwlib/src/hwmgr/soc_cv_av/alt_fpga_manager.c
  ${CMAKE_CURRENT_BINARY_DIR}/src/hwlib/src/hwmgr/soc_cv_av/alt_clock_manager.c
  ${CMAKE_CURRENT_BINARY_DIR}/src/hwlib/src/hwmgr/alt_watchdog.c
  ${CMAKE_CURRENT_BINARY_DIR}/src/hwlib/src/hwmgr/alt_timers.c
  ${CMAKE_CURRENT_BINARY_DIR}/src/hwlib/src/hwmgr/alt_spi.c
  ${CMAKE_CURRENT_BINARY_DIR}/src/hwlib/src/hwmgr/alt_mmu.c
  ${CMAKE_CURRENT_BINARY_DIR}/src/hwlib/src/hwmgr/alt_interrupt.c
  ${CMAKE_CURRENT_BINARY_DIR}/src/hwlib/src/hwmgr/alt_globaltmr.c
  ${CMAKE_CURRENT_BINARY_DIR}/src/hwlib/src/hwmgr/alt_generalpurpose_io.c
  ${CMAKE_CURRENT_BINARY_DIR}/src/hwlib/src/hwmgr/alt_dma_program.c
  ${CMAKE_CURRENT_BINARY_DIR}/src/hwlib/src/hwmgr/alt_cache.c

  ${CMAKE_CURRENT_SOURCE_DIR}/bare_metal_example.c

  )
#####


include_directories( ${CMAKE_CURRENT_BINARY_DIR}/src/hwlib/include )
include_directories( ${CMAKE_CURRENT_BINARY_DIR}/src/hwlib/include/soc_cv_av )


# bare-metal executable
add_executable( ${TARGET_AXF_NAME} ${SOURCE_FILES} )
target_link_libraries(${TARGET_AXF_NAME} m)
add_custom_command(
  OUTPUT  ${TARGET_BIN_PATH}
  COMMAND arm-altera-eabi-objcopy -O binary -v ${TARGET_AXF_PATH} ${TARGET_BIN_PATH}
  DEPENDS  ${TARGET_AXF_PATH}
  COMMENT "objcopying  ${TARGET_AXF_PATH} to ${TARGET_BIN_PATH}")
add_custom_target( ${TARGET_BIN_NAME} ALL DEPENDS ${TARGET_BIN_PATH})


# Pre-loader and u-boot targets
add_custom_command(
  OUTPUT ${PRELOADER_DIR}/Makefile
  COMMAND bsp-generate-files --settings ${CMAKE_CURRENT_SOURCE_DIR}/preloader/settings.bsp --bsp-dir ${PRELOADER_DIR}
  DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/preloader/settings.bsp
  COMMENT "Creating BSP"
  )
add_custom_command(
  OUTPUT ${PRELOADER_DIR}/preloader-mkpimage.bin
  COMMAND make -C ${PRELOADER_DIR}
  DEPENDS ${PRELOADER_DIR}/Makefile
  COMMENT "Building BSP"
  )
add_custom_command(
  OUTPUT ${PRELOADER_DIR}/uboot-socfpga/${UBOOT_NAME}
  COMMAND make -C ${PRELOADER_DIR} uboot
  DEPENDS ${PRELOADER_DIR}/Makefile
  COMMENT "Building U-Boot"
  )
add_custom_target( preloader DEPENDS ${PRELOADER_DIR}/preloader-mkpimage.bin    )
add_custom_target( uboot     DEPENDS ${UBOOT_PATH} )

# u-boot script target
add_custom_command(
  OUTPUT ${BOOT_SCR_PATH}
  COMMAND mkimage -A arm -T script -O linux -d ${BOOTTXT} ${BOOT_SCR_PATH}
  DEPENDS ${BOOTTXT}
  COMMENT "Creating boot.scr"
  )

# SD-Card target
add_custom_command(
  OUTPUT ${SDCARD_NAME}

  # MBR
  COMMAND dd if=/dev/zero of=${SDCARD_NAME}.01.tmp bs=512 count=2048

  # Preloader partition
  COMMAND cp ${PRELOADER_DIR}/preloader-mkpimage.bin ${SDCARD_NAME}.02.tmp
  COMMAND truncate --size=1M ${SDCARD_NAME}.02.tmp

  # FAT Partition
  COMMAND dd if=/dev/zero of=${SDCARD_NAME}.03.tmp bs=512 count=${SDCARD_SIZE}
  COMMAND /usr/sbin/mkfs.vfat -v ${SDCARD_NAME}.03.tmp
  COMMAND mcopy -i ${SDCARD_NAME}.03.tmp ${TARGET_BIN_PATH}    ::${TARGET_BIN_NAME}
  COMMAND mcopy -i ${SDCARD_NAME}.03.tmp ${UBOOT_PATH}         ::${UBOOT_NAME}
  COMMAND mcopy -i ${SDCARD_NAME}.03.tmp ${BOOT_SCR_PATH}      ::${BOOT_SCR_NAME}
  COMMAND mcopy -i ${SDCARD_NAME}.03.tmp ${FPGARBF_PATH}       ::${SOC_RBF_NAME}
  COMMAND cat ${SDCARD_NAME}.01.tmp  > ${SDCARD_NAME}.tmp
  COMMAND cat ${SDCARD_NAME}.02.tmp >> ${SDCARD_NAME}.tmp
  COMMAND cat ${SDCARD_NAME}.03.tmp >> ${SDCARD_NAME}.tmp
  COMMAND bash ${CMAKE_CURRENT_SOURCE_DIR}/fdisk.sh ${SDCARD_NAME}.tmp
  COMMAND mv ${SDCARD_NAME}.tmp ${SDCARD_NAME}
  COMMAND rm ${SDCARD_NAME}.01.tmp
  COMMAND rm ${SDCARD_NAME}.02.tmp
  COMMAND rm ${SDCARD_NAME}.03.tmp
  DEPENDS ${PRELOADER_DIR}/preloader-mkpimage.bin
  DEPENDS ${UBOOT_PATH}
  DEPENDS ${BOOT_SCR_PATH}
  DEPENDS ${TARGET_BIN_PATH}
  COMMENT "Creating sd-card file"
  )
add_custom_target( sdcard DEPENDS ${SDCARD_NAME} )

add_custom_target( program COMMAND 	quartus_pgm ${CDF_PATH} )

