
#include <stdio.h>

#if defined(__is_libk)
#include <kernel/tty.h>
#endif

int
putchar(int ic)
{
#if defined(__is_libk)
	char c = (char) ic;
	__tty_put_entry(c);
#else
	/* TODO: implement syscalls, write. */
#endif
	return ic;
}

