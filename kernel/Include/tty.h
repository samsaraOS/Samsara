#if !defined(__tty_h__)
#define __tty_h__

int
__tty_init(void);

void
__tty_set_color(uint8_t, uint8_t);

void
__tty_put_entry(char);


#endif

