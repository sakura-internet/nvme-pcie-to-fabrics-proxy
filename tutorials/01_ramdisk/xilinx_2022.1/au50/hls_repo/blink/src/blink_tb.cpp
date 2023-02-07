#include <stdio.h>

#include "common.h"
#include "blink.h"

int main()
{
	UINT32 gpio_out = 0x00000000;
	for (int i = 0; i < 100; i ++) {
		blink(&gpio_out);
		printf("gpio_out : 0x%08x\n", (int)gpio_out);
	}
	return 0;
}
