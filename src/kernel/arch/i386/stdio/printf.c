/** 
 * BSD 3-Clause License
 * 
 * Copyright (c) 2018, Samsara OS
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * * Neither the name of the copyright holder nor the names of its
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
 */

#include <limits.h>
#include <stdbool.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>

static int 
print(const char* data, size_t length) 
{
	const unsigned char* bytes = (const unsigned char*) data;

	for (size_t i = 0; i < length; i++)
		if (putchar(bytes[i]) == EOF)
			return 0;
	return 1;
}

static void
__reverse(char str[])
{
	int i;
	char tmp[64];
	size_t len;

	len = strlen(str) - 1;
	memset(tmp, 0, 64);

	for (i = 0; i <  64; i++)
		tmp[i] = str[len-i];
	for (i = 0; i < 64; i++)
		str[i] = tmp[i];
	str[i++] = '\0';
}

static void
__itoa(int n, char str[])
{
	int pos;
	int sign;

	pos = 0;
	sign = n;

	if (sign < 0)
		n = -n;

	do {
		str[pos] = (n % 10) + '0';
		n = n / 10;
		pos++;
	} while (n > 0 &&
		pos < 16);

	if (sign < 0) {
		str[pos] = '-';
		pos++;
	}

	str[pos] = '\0';
	__reverse(str);


}

static void
__itox(unsigned int n, char str[])
{
	int pos;

	pos = 0;
	do {
		str[pos] = "0123456789ABCDEF"[n & 0x0F];
		n = n >> 4;
		pos++;
	} while (n != 0 
		&& pos < 16);

	str[pos] = '\0';
	__reverse(str);
}

int 
printf(const char* restrict format, ...) 
{
	va_list parameters;
	va_start(parameters, format);

	char num_str[64];
	int written = 0;

	while (*format != '\0') {
		memset(num_str, 0, 64);
		size_t maxrem = INT_MAX - written;

		if (format[0] != '%' || format[1] == '%') {
			if (format[0] == '%')
				format++;
			size_t amount = 1;
			while (format[amount] && format[amount] != '%')
				amount++;
			if (maxrem < amount) {
				// TODO: Set errno to EOVERFLOW.
				return -1;
			}
			if (!print(format, amount))
				return -1;
			format += amount;
			written += amount;
			continue;
		}

		const char* format_begun_at = format++;

		if (*format == 'c') {
			format++;
			char c = (char) va_arg(parameters, int /* char promotes to int */);
			if (!maxrem) {
				// TODO: Set errno to EOVERFLOW.
				return -1;
			}
			if (!print(&c, sizeof(c)))
				return -1;
			written++;
		} else if (*format == 's') {
			format++;
			const char* str = va_arg(parameters, const char*);
			size_t len = strlen(str);
			if (maxrem < len) {
				// TODO: Set errno to EOVERFLOW.
				return -1;
			}
			if (!print(str, len))
				return -1;
			written += len;
		} else if (*format == 'd') {
			format++;
			const int num = va_arg(parameters, const int);
			__itoa(num, num_str);
			size_t len = strlen(num_str);
			if (maxrem < len) {
				return -1;
			}
			if (!print(num_str, len))
				return -1;
			written += len;
		} else if (*format == 'x') {
			format++;
			const unsigned int hex = va_arg(parameters, const unsigned int);
			__itox(hex, num_str);
			size_t len = strlen(num_str);
			if (maxrem < len) {
				return -1;
			}
			if (!print(num_str, len))
				return -1;
			written++;
		} else {
			format = format_begun_at;
			size_t len = strlen(format);
			if (maxrem < len) {
				// TODO: Set errno to EOVERFLOW.
				return -1;
			}
			if (!print(format, len))
				return -1;
			written += len;
			format += len;
		}
	}

	va_end(parameters);
	return written;
}
