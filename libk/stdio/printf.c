
/**
 * basic printf() function.
 */

#include <limits.h>
#include <stdbool.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>

int
print(const char *str, size_t len)
{
	const unsigned char *bytes = (const unsigned char*)str;
	size_t i;

	for (i = 0; i < len; i++)
		if (putchar(bytes[i]) == EOF)
			return 0;
	return 1;
}

int
printf(const char *restrict format, ...)
{
	size_t maxrem, amount;
	size_t len;
	va_list parameters;
	int written;
	char *str;
	const char *fmt_bad;
	char c;
	
	va_start(parameters, format);

	while (*format != 0x00) {
		maxrem = INT_MAX - written;

		if (format[0] != '%' || format[1] == '%') {
			if (format[0] == '%')
				format++;
			amount = 1;
			while (format[amount] && format[amount] != '%')
				amount++;
			if (maxrem < amount) {
				/* set_errno(EOVERFLOW); */
				return -1;
			}
			if (!print(format, amount))
				return -1;
			format += amount;
			written += amount;
			continue;
		}

		fmt_bad = format++;

		if (*format == 'c') {
			format++;
			c = (char) va_arg(parameters, int);
			if (!maxrem) {
				/* set_errno(EOVERFLOW) */
				return -1;
			}
			if (!print(&c, sizeof(c)))
				return -1;
			written++;
		} else if (*format == 's') {
			format++;
			str = va_arg(parameters, char *);
			len = strlen(str);
			if (maxrem < len) {
				/* set_errno(EOVERFLOW); */
				return -1;
			}
			if (!print(str, len))
				return -1;
			written += len;
		} else if (*format == 'd') {
			format++;
			itoa(va_arg(parameters, int), str);
			len = strlen(str);
			if (maxrem < len) {
				/* set errno */
				return -1;
			}
			if (!print(str, len))
				return -1;
			written += len;
		} else {
			format = fmt_bad;
			len = strlen(format);
			if (maxrem < len) {
				/* set errno */
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


