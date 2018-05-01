
#include <stdlib.h>
#include <string.h>

void
itoa(int n, char s[])
{
	/*	must check if s points to a writeable area, not kernel code!
		is_mem_writeable(void *addr, size_t len) or something like that
		must be implemented later to avoid arbitrary writes.
	*/
	int i;
	int j;
	int sign;
	char c;

	if ((sign = n) < 0)
		n *= -1;
	i = 0;
	do {
		s[i++] = n % 10 + '0';
	} while ((n /= 10) > 0);
	if (sign < 0)
		s[i++] = '-';
	s[i] = '\0';

	for (i = 0, j = strlen(s)-1; i < j; i++, j--) {
		c = s[i];
		s[i] = s[j];
		s[j] = c;
	}
}
