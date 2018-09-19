# BSD 3-Clause License
# 
# Copyright (c) 2018, Samsara OS
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# 
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# 
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

CC=i686-elf-gcc
AS=nasm

CFLAGS?=-O2 -g
lDFLAGS?=
LIBS?=

DESTDIR=sysroot
PREFIX?=/usr/local
EXEC_PREFIX?=$(PREFIX)
BOOT_DIR?=$(EXEC_PREFIX)/boot
INCLUDE_DIR?=$(PREFIX)/include

LIBDIR=$(EXEC_PREFIX)/lib

CFLAGS:=$(CFLAGS) -ffreestanding -Wall -Wextra
LDFLAGS:=$(LDFLAGS)
LIBS:=$(LIBS) -nostdlib -lgcc

ARCHDIR=src/kernel/arch/i386
LIBK_ARCHDIR=src/libk/arch/i386

include $(ARCHDIR)/make.config
include $(LIBK_ARCHDIR)/make.config

CFLAGS:=$(CFLAGS) $(KARCH_CFLAGS)
LDFLAGS:=$(LDFLAGS) $(KARCH_LDFLAGS)
LIBS:=$(LIBS) $(KARCH_LIBS)

LIBK_CFLAGS:=$(CFLAGS) $(KARCH_CFLAGS)

LIBK_FREE_OBJS=\
	$(ARCH_FREEOBJS) \
	src/libk/stdio/printf.o \
	src/libk/stdio/putchar.o \
	src/libk/stdio/puts.o \
	src/libk/stdlib/abort.o \
	src/libk/string/memcmp.o \
	src/libk/string/memcpy.o \
	src/libk/string/memmove.o \
	src/libk/string/memset.o \
	src/libk/string/strlen.o

LIBK_HOSTEDOBJS=\
	$(LIBK_ARCH_HOSTEDOBJS)

LIBK_OBJS=\
	$(LIBK_FREE_OBJS) \
	$(LIBK_HOSTEDOBJS)

LIBK_OBJS_FINAL=$(LIBK_FREE_OBJS:.o=.libk.o)

# Add libc when it's possible to implement :)
BINARIES=libk.a

KERN_OBJS=\
	$(KARCH_OBJS) \
	src/kernel/kernel/kernel.o

OBJS=\
	$(ARCHDIR)/cruntime/crti.o \
	$(ARCHDIR)/cruntime/crtbegin.o \
	$(KERN_OBJS) \
	$(ARCHDIR)/cruntime/crtend.o \
	$(ARCHDIR)/cruntime/crtn.o

LINK_LIST=\
	$(LDFLAGS) \
	$(ARCHDIR)/cruntime/crti.o \
	$(ARCHDIR)/cruntime/crtbegin.o \
	$(KERN_OBJS) \
	$(LIBS) \
	$(ARCHDIR)/cruntime/crtend.o \
	$(ARCHDIR)/cruntime/crtn.o 

.PHONY: all clean install install-headers install-kernels
.SUFFIXES: .o .libk.o .c .asm

all: install-headers libk_install-headers libk_all samsara.kernel
	mv samsara.kernel bin/

samsara.kernel: $(OBJS) $(ARCHDIR)/linker.ld
	$(CC) -T $(ARCHDIR)/linker.ld -o $@ $(CFLAGS) $(LINK_LIST)

$(ARCHDIR)/cruntime/crtbegin.o $(ARCHDIR)/cruntime/crtend.o:
	OBJ=`$(CC) $(CFLAGS) $(LDFLAGS) -print-file-name=$(@F)` && cp "$$OBJ" $@

.c.o:
	$(CC) -MD -I sysroot/usr/local/include -c $< -o $@ -std=gnu11 $(CFLAGS)
.asm.o:
	$(AS) -felf32 -o $@ $<

clean:
	rm -rf sysroot
	rm -rf $(BINARIES)
	rm -rf $(LIBK_OBJS) *.o */*.o */*/*.o
	rm -rf $(LIBK_OBJS:.o=.d) *.d */*.d */*/*.d */*/*/*.d
	rm -rf samsara.kernel
	rm -rf $(OBJS) *.o */*.o */*/*.o */*/*/*.o
	rm -rf $(OBJS:.o=.d) *.d */*.d */*/*.d */*/*/*.d
	rm -rf bin/*

install: install-headers install-kernel

install-headers:
	mkdir -p $(DESTDIR)$(INCLUDE_DIR)
	cp -r src/kernel/include/* $(DESTDIR)$(INCLUDE_DIR)/.

install-kernel: samsara.kernel
	mkdir -p $(DESTDIR)$(BOOTDIR)
	cp samsara.kernel $(DESTDIR)$(BOOTDIR)

libk_all: $(BINARIES)

libk.a: $(LIBK_OBJS_FINAL)
	$(AR) rcs $@ $(LIBK_OBJS_FINAL)

.c.libk.o:
	$(CC) -MD -I sysroot/usr/local/include -c $< -o $@ -std=gnu11 $(LIBK_CFLAGS)

libk_install: libk_install-headers libk_install-libs

libk_install-headers:
	mkdir -p $(DESTDIR)$(INCLUDE_DIR)
	cp -r src/libk/include/* $(DESTDIR)$(INCLUDE_DIR)/.

libk_install-libs:
	mkdir -p $(DESTDIR)$(LIBDIR)
	cp $(BINARIES) $(DESTDIR)$(LIBDIR)

-include $(OBJS:.o=.d)
-include $(LIBK_OBJS:.o=.d)
 

