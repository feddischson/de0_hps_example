
TARGET = bare_metal_example


QSYS_HEADERS = ../../soc/qsys_headers
CFLAGS = -g -Wall  -I $(QSYS_HEADERS)
LDFLAGS =  -g -Wall 
SRC=bare_metal_example.c

build: $(TARGET)

$(TARGET): bare_metal_example.o
	$(CC) $(LDFLAGS)   $^ -o $@ 

%.o : %.c
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: preloader
preloader: preloader/generated/build.h

preloader/generated/build.h: preloader/settings.bsp
	bsp-generate-files --settings preloader/settings.bsp --bsp-dir ./preloader
	make -C preloader

.PHONY: clean
clean:
	rm -rf $(TARGET) *.a *.o \
	  preloader/generated \
	  preloader/uboot-socfpga \
	  preloader/*.ds \
	  preloader/*.bin  \
	  preloader/Makefile

