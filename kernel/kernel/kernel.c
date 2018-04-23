
#include <stdint.h>
#include <tty.h>

int
kmain()
{
	int ret;

	ret = __tty_init();
	if (ret) {
		return ret;
	}

	__tty_put_entry('Y');
	__tty_put_entry('e');
	__tty_put_entry('s');
	

	return 0;
}

