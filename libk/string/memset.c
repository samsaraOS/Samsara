
#include <string.h>

void *
memset(void *ptr, int byte, size_t len)
{
	size_t i;
	
	for (i = 0; i < len; i++)
		((unsigned char *)ptr)[i] = byte;
	return ptr;
}

