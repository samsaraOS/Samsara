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

static uint16_t * const __tty_vmaddr = (uint16_t*)0xb8000;
static uint8_t __tty_row;
static uint8_t __tty_column;
static uint8_t __tty_color;
static uint16_t *__tty_buf_ptr;

/**
 * __tty_init(void) loops through the whole 80x24 VGA Framebuffer,
 * setting every character to be black empty space (' ').
 *
 * NOTE: __tty_init is set to be int always returning 0, so
 * that we can perform sanity-check on it with kernel.c
 */
int
__tty_init(void)
{
	uint8_t x, y;
	size_t addr;

	__tty_row = 0;
	__tty_column = 0;
	__tty_color = VGA_SET_COLOR(VGA_LGREY, VGA_BLACK);
	__tty_buf_ptr = __tty_vmaddr;

	for (y = 0; y < VGA_HEIGHT; y++) {
		for (x = 0; x < VGA_WIDTH; x++) {
			addr = y * VGA_WIDTH + x;
			__tty_buf_ptr[addr] = VGA_ENTRY(' ', __tty_color);
		}
	}
	return 0;
}

void
__tty_roll_down(void)
{
	size_t addr;
	size_t old_addr;
	uint8_t x, y;

	for (y = 1; y < 24; y++) {
		for (x = 0; x < VGA_WIDTH; x++) {
			addr = (y - 1) * VGA_WIDTH + x;
			old_addr = y * VGA_WIDTH + x;
			__tty_buf_ptr[addr] = __tty_buf_ptr[old_addr];
		}
	}
}

/**
 * Helper for __tty_put_entry(uint8_t)
 */
void
__tty_putat(unsigned char c)
{
	size_t addr;
	addr = __tty_row * VGA_WIDTH + __tty_column;
	__tty_buf_ptr[addr] = VGA_ENTRY(c, __tty_color);
}

/**
 * __tty_put_entry(uint8_t c) sets next character
 * of the VGA Coordinates to be character provided.
 */
void
__tty_put_entry(char c)
{
	__tty_putat((unsigned char)c);
	
	if (++__tty_column == 80) {
		__tty_column = 0;
		if (++__tty_row == 24) {
			__tty_roll_down();
		}
	}
}

/**
 * __tty_set_color(uint8_t fg, uint8_t bg)
 * sets VGA colors to be fg | bg << 4.
 * VGA_<volor> defined colors from vga.h should be used.
 */
void
__tty_set_color(uint8_t fg, uint8_t bg)
{
	__tty_color = VGA_SET_COLOR(fg, bg);
}




