/**
 * This file defines functions used for
 * writing text to framebuffer.
 * 
 * NOTE: These functions should all start with
 * __tty prefix (eg, __tty_init(...)), as
 * these are not ment to be used by kernel directly,
 * but by printf() and other stdio functions.
 * 
 * NOTE: All the functionality should be in such form that
 * it works on both 32- and 64-bit mode.
 * 
 */

#include <stdint.h>
#include <tty.h>
#include "vga.h" 	/* VGA Definitions (colors etc.) */

static const uint32_t *__tty_vmaddr = (uint32_t*)0xb8000;
static uint8_t __tty_row;
static uint8_t __tty_column;
static uint8_t __tty_color;
static uint16_t *__tty_buf_ptr;

int
__tty_test(void)
{
	return 2;
}

void
__tty_init(void)
{
	uint8_t x, y;
	uint16_t addr;

	__tty_row = 0;
	__tty_column = 0;
	__tty_color = VGA_COLOR(VGA_LGREY, VGA_BLACK);
	__tty_buf_ptr = __tty_vmaddr;

	for (y = 0; y < VGA_HEIGHT; y++) {
		for (x = 0; x < VGA_WIDTH; x++) {
			addr = y * VGA_WIDTH + x;
			__tty_buf_ptr[addr] = VGA_ENTRY(' ', __tty_color);
		}
	}
}









