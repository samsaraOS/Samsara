
#include <string.h>

void *
memmove(void *dst, const void *src, size_t size)
{
	size_t i;
	unsigned char *dstptr;
	unsigned char *srcptr;

	dstptr = (unsigned char *)dst;
	srcptr = (unsigned char *)src;

	if (dst < src) {
		for (i = 0; i < size; i++)
			dst[i] = src[i];
	} else {
		for (i = size; i != 0; i--)
			dst[i-1] = src[i-1];
	}
	return dst;
}


