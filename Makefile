
cc=i686-elf-gcc
cflags=-Wall -Wextra -ffreestanding
as=nasm

destdir=sysroot
prefix=/usr/local
exec_prefix=$(prefix)
bootdir=$(exec_prefix)/boot
includedir=$(prefix)/include

include src/kernel/arch/x86/make.config

kernel_objs=\
	       $(kernel_arch_objs) \
	       src/kernel/kernel/kernel.o \

objs=\
     src/kernel/arch/x86/boot/crti.o \
     src/kernel/arch/x86/crtbegin.o \
     $(kernel_objs) \
     src/kernel/arch/x86/crtend.o \
     src/kernel/arch/x86/boot/crtn.o \

link_list=\
	  $(ldflags) \
	  src/kernel/arch/x86/boot/crti.o \
	  src/kernel/arch/x86/crtbegin.o \
	  $(kernel_objs) \
	  src/kernel/arch/x86/crtend.o \
	  src/kernel/arch/x86/boot/crtn.o \

.PHONY: all clean bootloader install install-headers install-kernel
.SUFFIXES: .o .c .s

all: samsara.kernel

samsara.kernel: $(objs) src/kernel/arch/x86/linker.ld
	$(cc) -nostdlib -lgcc -T src/kernel/arch/x86/linker.ld -o $@ $(cflags) $(link_list)

src/kernel/arch/x86/crtbegin.o src/kernel/arch/x86/crtend.o:
	OBJ=`$(cc) $(cflags) $(ldflags) -print-file-name=$(@F)` && cp "$$OBJ" $@

.c.o:
	$(cc) -MD -c $< -o $@ -std=gnu11 $(cflags)
.s.o:
	$(as) -felf32 -o $@ $<
clean:
	rm -f samsara.kernel
	rm -f *.bin
	rm -f $(objs) *.o */*.o */*/*.o */*/*/*.o
	rm -f $(objs:.o=.d) *.d */*.d */*/*.d */*/*/*.d

install: bootloader install-headers install-kernel

install-headers:
	mkdir -p $(destdir)$(includedir)
	cp -r include $(destdir)$(includedir)

install-kernel: samsara.kernel
	mkdir -p $(destdir)$(bootdir)
	cp samsara.kernel $(destdir)$(bootdir)

bootloader:
	nasm -f bin -o bootloader.bin src/bootloader/boot.s

