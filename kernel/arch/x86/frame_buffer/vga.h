#if !defined(__framebuffer_vga_h__)
#define __framebuffer_vga_h__

#include <stdint.h>

#define VGA_HEIGHT 24
#define VGA_WIDTH 80

enum VGA_COLOR {
	VGA_BLACK = 0,
	VGA_BLUE = 1,
	VGA_GREEN = 2,
	VGA_CYAN = 3,
	VGA_RED = 4,
	VGA_MAGENTA = 5,
	VGA_BROWN = 6,
	VGA_LGREY = 7,
	VGA_DGREY = 8,
	VGA_LBLUE = 9,
	VGA_LGREEN = 10,
	VGA_LCYAN = 11,
	VGA_LRED = 12,
	VGA_LMAGENTA = 13,
	VGA_LBROWN = 14,
	VGA_WHITE = 15,
};

static inline uint8_t
VGA_SET_COLOR(enum VGA_COLOR fg, enum VGA_COLOR bg)
{
	return fg | bg << 4;
}

static inline uint16_t
VGA_ENTRY(unsigned char c, uint8_t colo)
{
	return (uint16_t) c | (uint16_t) colo << 8;
}

#endif


