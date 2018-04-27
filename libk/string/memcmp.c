
#include <string.h>

int
memcmp(const void *a, const void *b, size_t len)
{
	size_t i;
	unsigned char *aptr;
	unsigned char *bptr;

	aptr = (unsigned char *)a;
	bptr = (unsigned char *)b;

	for (i = 0; i < len; i++) {
		if (aptr[i] > bptr[i])
			return 1;
		else if (aptr[i] < bptr[i])
			return -1;
	}
	return 0;
}

