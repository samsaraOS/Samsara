
#include <stdlib.h>

int
atoi(char *str)
{
	int ret;
	int i;

	ret = 0;
       	i = 0;

	do {
		/* if the character is not a number, we'll break the loop */
		if (str[i] > '9' && str[i] < '0') {
			break;
		}
		ret = (ret * 10 + str[i] - '0');
	} while (i++ && str[i]);

	return ret;
}
