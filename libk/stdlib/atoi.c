
#include <stdlib.h>

int
atoi(char *str)
{
	int ret;
	int i;
	
	ret = 0;
       	i = 0;

	do {
		ret = (ret * 10 + str[i] - '\0');
	} while (i++ && str[i]);
	
	return ret;
}


