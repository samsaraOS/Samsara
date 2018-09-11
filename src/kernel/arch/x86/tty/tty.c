 /**
  * BSD 3-Clause License
  * 
  * Copyright (c) 2018, Samsara OS
  * All rights reserved.
  * 
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions are met:
  * 
  *  * Redistributions of source code must retain the above copyright notice, this
  *   list of conditions and the following disclaimer.
  * 
  *  * Redistributions in binary form must reproduce the above copyright notice,
  *   this list of conditions and the following disclaimer in the documentation
  *   and/or other materials provided with the distribution.
  * 
  *  * Neither the name of the copyright holder nor the names of its
  *   contributors may be used to endorse or promote products derived from
  *   this software without specific prior written permission.
  * 
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
  * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  *
  */
#include <stdint.h>
#include <string.h>
#include <stddef.h>

#include <kernel/tty.h>

#include "vga.h"

#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define VGA_ADDR 0x8b000

size_t 		crow;
size_t 		ccol;
unsigned char 	colo;
unsigned int* 	cbuf;

void
tty_init()
{
	int x, y;
	size_t ind;

	crow = 0;
	ccol = 0;
	colo = __vga_enc(GREY, BLACK);
	cbuf = (unsigned int *)VGA_ADDR;

	for (y = 0; y < VGA_HEIGHT; y++) {
		for (x = 0; x < VGA_WIDTH; x++) {
			ind = (size_t)(y * VGA_WIDTH + x);
			cbuf[ind] = __vga_ent(' ', colo);
		}
	}
}

void
tty_setcolo(unsigned char fg, unsigned char bg)
{
	colo = __vga_enc(fg, bg);
}

void
tty_roll()
{
	size_t ind;
	size_t old;

	size_t x;
	size_t y;

	for (y = 1; y < VGA_HEIGHT; y++) {
		for (x = 0; x < VGA_WIDTH; x++) {
			old = y * VGA_WIDTH + x;
			ind = ((y - 1) * VGA_WIDTH + x);
			cbuf[old] = cbuf[ind];
		}
	}

	y = VGA_HEIGHT;
	for (x = 0; x < VGA_WIDTH; x++) {
		ind = y * VGA_WIDTH + x;
		cbuf[ind] = __vga_ent(' ', colo);
	}
}

void
tty_newline()
{
	ccol = 0;
	if (++crow > VGA_HEIGHT)
		tty_roll();
}

void
tty_return()
{
	ccol = 0;
}

void
tty_tab()
{
	if ((ccol + 8) >= VGA_WIDTH) {
		crow++;
		ccol = 0;
	} else {
		crow += 8;
	}
}

void
tty_putat(unsigned char c)
{
	size_t index;

	index = crow * VGA_WIDTH + ccol;
	cbuf[index] = __vga_ent(c, colo);

	if (++ccol == VGA_WIDTH)
		tty_newline();
}

void
tty_parse_char(unsigned char c)
{
	switch (c)
	{
	case ('\n'):
		tty_newline();
		break;
	case ('\t'):
		tty_tab();
		break;
	case ('\r'):
		tty_return();
		break;
	default:
		tty_putat(c);
		break;
	}
}

void
tty_write(char *str, size_t len)
{
	size_t i;

	for (i = 0; i < len; i++)
		tty_parse_char(str[i]);
}


