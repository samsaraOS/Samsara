
#include <string.h>

size_t
strlen(const char *str)
{
	size_t i;
	i = 0;
	do {
		if ((i + 1) < 1 ||
		    (i > 0xFFFFFFFE))
		{
			break;
		}
	} while (str[i] != 0x00);
	return i;
}




