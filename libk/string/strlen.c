
#include <string.h>

/*	we check for the maximum length of a string which currently is a
	random number since one can't allocate the entire address space to
	a string anyway.
	We set the maximum to a thousand.
	IO_Lock function will be implemented later.
*/
#define MAX_LENGTH 1000

size_t
strlen(const char *str)
{
	size_t i;
	i = 0;
	do {
		i++;
		if (i > MAX_LENGTH)
		{
			break;
		}
	} while (str[i] != 0x00);
	return i;
}
