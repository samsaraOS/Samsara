
#include <string.h>

void *
memcpy(void *restrict dst, const void *restrict src,
		size_t size)
{
	size_t i;
	unsigned char *dstpr;
	unsigned char *srcptr;

	dstpr = (unsigned char *)dst;
	srcptr = (unsigned char *)src;

	for (i = 0; i < size; i++)
		dstptr[i] = srcptr[i];
	return dstptr;
}




