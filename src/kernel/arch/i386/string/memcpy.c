#include <string.h>

void* 
memcpy(void* restrict dstptr, void* srcptr, size_t size) 
{
	unsigned char *dst;
	unsigned char *src;

	dst = (unsigned char*) dstptr;
	src = (unsigned char*) srcptr;


	for (size_t i = 0; i < size; i++)
		dst[i] = src[i];
	return dstptr;
}
