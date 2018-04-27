
#include <kernel/tty.h>
#include <kernel/asm.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

void
test(char *str)
{
	__tty_put_entry(str[0]);
	asm volatile("cli");
	asm volatile("hlt");
}

int
kmain()
{
	int ret;
	char buf[] = "Hello";

	ret = __tty_init();
	if (ret) {
		return ret;
	}
	test((char *)&buf);

	return 0;
}

