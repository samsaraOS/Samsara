
#include <kernel/tty.h>

int
kmain()
{
	tty_write("HELLO\n", 6);
}


