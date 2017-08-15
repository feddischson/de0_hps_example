
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

.PHONY: clean
clean:
	rm -f $(TARGET) *.a *.o

