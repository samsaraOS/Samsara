
cc=i686-elf-gcc
cflags=-Wall -Wextra -ffreestanding
as=nasm
libk_cflags=-Wall -Wextra -ffreestanding -g

destdir=sysroot
prefix=/usr/local
exec_prefix=$(prefix)
bootdir=$(exec_prefix)/boot
includedir=$(prefix)/include
libdir=$(prefix)/lib

include kernel/arch/x86/make.config
include libk/make.config

kernel_objs=\
	       $(kernel_arch_objs) \
	       kernel/kernel/kernel.o \

objs=\
     kernel/arch/x86/boot/crti.o \
     kernel/arch/x86/crtbegin.o \
     $(kernel_objs) \
     kernel/arch/x86/crtend.o \
     kernel/arch/x86/boot/crtn.o \

link_list=\
	  $(ldflags) \
	  kernel/arch/x86/boot/crti.o \
	  kernel/arch/x86/crtbegin.o \
	  $(kernel_objs) \
	  $(lib_objs) \
	  libk.a \
	  kernel/arch/x86/crtend.o \
	  kernel/arch/x86/boot/crtn.o \

.PHONY: all clean bootloader install headers kernel libs
.SUFFIXES: .o .libk.o .c .s

all: install

libk.a: $(libk_objs)
	i686-elf-ar rcs $@ $(libk_objs)

samsara.kernel: $(objs) kernel/arch/x86/linker.ld
	$(cc) -nostdlib -lgcc -T kernel/arch/x86/linker.ld -o $@ $(cflags) $(link_list)

kernel/arch/x86/crtbegin.o kernel/arch/x86/crtend.o:
	OBJ=`$(cc) $(cflags) $(ldflags) -print-file-name=$(@F)` && cp "$$OBJ" $@

.c.o:
	$(cc) -I sysroot/usr/local/include/ -MD -c $< -o $@ -std=gnu11 $(cflags)

.c.libk.o:
	$(cc) -I sysroot/usr/local/include -MD -c $< -o $@ $(libk_cflags)

.s.o:
	$(as) -felf32 -o $@ $<
clean:
	rm -f libk.a
	rm -f SamsaraOS
	rm -rf sysroot
	rm -f samsara.kernel
	rm -f *.bin
	rm -f $(objs) *.o */*.o */*/*.o */*/*/*.o
	rm -f $(objs:.o=.d) *.d */*.d */*/*.d */*/*/*.d

install: headers libs samsara.kernel bootloader
	dd if=samsara.kernel >> bootloader.bin && \
		mv bootloader.bin SamsaraOS

headers:
	mkdir -p $(destdir)$(includedir)
	cp -r kernel/Include/* $(destdir)$(includedir)

libs: libk.a
	mkdir -p $(destdir)$(libdir)
	cp libk.a $(destdir)$(libdir)

bootloader:
	nasm -f bin -o bootloader.bin bootloader/boot.s

