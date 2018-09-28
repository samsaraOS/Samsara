#include <string.h>

size_t 
strlen(const char* str) 
{
	size_t len;

	len = 0;
	while (str[len] && len < 1000)
		len++;
	return len;
}
