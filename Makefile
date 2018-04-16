
cc=i686-elf-gcc
cflags=-Wall -Wextra -ffreestanding
as=nasm
libs=-nostdlib -lk -lgcc

destdir=sysroot
prefix=/usr/local
exec_prefix=$(prefix)
bootdir=$(exec_prefix)/boot
includedir=$(prefix)/include

bootloader:
	nasm -f bin -o samsara_loader.bin src/bootloader/boot.s

include src/kernel/arch/x86/make.config

kernel_objects=\
	       kernel_arch_objects \
	       src/kernel/kernel.o \

objs=\
     src/kernel/arch/x86/boot/crti.o \
     src/kernel/arch/x86/crtbegin.o \
     $(kernel_objects) \
     $(libs) \
     src/kernel/arch/x86/crtend.o \
     src/kernel/arch/x86/boot/crtn.o \

link_list=\
	  $(ldflags) \
	  src/kernel/arch/x86/boot/crti.o \
	  src/kernel/arch/x86/crtbegin.o \
	  $(kernel_objects) \
	  $(libs) \
	  src/kernel/arch/x86/crtend.o \
	  src/kernel/arch/x86/boot/crtn.o \

.PHONY: all clean bootloader install install-headers install-kernel
.SUFFIXES: .o .c .S

all: samsara.kernel

samsara.kernel: bootloader $(objs) src/kernel/arch/x86/linker.ld
	$(cc) -T src/kernel/arch/x86/linker.ld -o $@ $(cflags) $(link_list)

src/kernel/arch/x86/crtbegin.o src/kernel/arch/x86/crtend.o:
	OBJ=`$(cc) $(cflags) $(ldflags) -print-file-name=$(@F)` && cp "$$OBJ" $@

.c.o:
	$(cc) -MD -c $< -o $@ -std=gnu11 $(cflags)
.S.o:
	$(as) -felf32 -o $@ $<
clean:
	rm -rf samsara.kernel
	rm -rf $(objs) *.o */*.o */*/*.o */*/*/*.o
	rm -rf $(objs:.o=.d) *.d */*.d */*/*.d */*/*/*.d

install: bootloader install-headers install-kernel

install-headers:
	mkdir -p $(destdir)$(includedir)

