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

#if !defined(__VGA_H__)
#define __VGA_H__

#include <stdint.h>

#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define VGA_ADDR 0xb8000

enum 
VGA_COLOR_MAP
{
	BLACK 		= 0, 
	BLUE 		= 1,
	GREEN 		= 2,
	CYAN 		= 3,
	RED 		= 4,
	MAGENTA 	= 5,
	BROWN 		= 6,
	GREY 		= 7,
	DARK_GREY	= 8,
	BRIGHT_BLUE 	= 9,
	BRIGHT_GREEN 	= 10, 
	BRIGHT_CYAN 	= 11,
	BRIGHT_RED 	= 12,
	BRIGHT_MAGENTA	= 13,
	BRIGHT_YELLOW	= 14,
	WHITE 		= 15
};

static inline uint8_t
__vga_enc(enum VGA_COLOR_MAP fg, enum VGA_COLOR_MAP bg)
{
	return (fg | bg << 4);
}

static inline uint16_t
__vga_ent(uint8_t c, uint8_t colo)
{
	return ((uint16_t)c | (uint16_t)colo << 8);
}

#endif

