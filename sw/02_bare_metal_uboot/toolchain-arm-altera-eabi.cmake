# Target system
SET(CMAKE_SYSTEM_NAME Generic )
SET(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR arm)

if( "$ENV{SOCEDS_DEST_ROOT}" STREQUAL "" )
  message( FATAL_ERROR "No SOC-EDS Varialbe (SOCEDS_DEST_ROOT) found. Please run embedded_command_shell.sh" )
endif()


set(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "")
set(CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS "")
set(CMAKE_FIND_ROOT_PATH $ENV{SOCEDS_DEST_ROOT}/host_tools/mentor/gnu/arm/baremetal )

# Cross compiler
SET(CMAKE_C_COMPILER    $ENV{SOCEDS_DEST_ROOT}/host_tools/mentor/gnu/arm/baremetal/bin/arm-altera-eabi-gcc )
SET(CMAKE_CXX_COMPILER  $ENV{SOCEDS_DEST_ROOT}/host_tools/mentor/gnu/arm/baremetal/bin/arm-altera-eabi-g++ )

# Search for programs in the build host directories
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

# Libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
