#include "dt-core.h"

static unsigned int
super(void)
{
	dt_ymd_t x = {0};
	unsigned int super = 0;

	for (int y = 1917; y < 2199; y++) {
		for (int m = 1; m <= 12; m ++) {
			for (int d = 1; d <= 28; d++) {
				dt_dow_t w;
				x.y = y;
				x.m = m;
				x.d = d;
				w = __ymd_get_wday(x);
				super += y * m * w + d;
			}
		}
	}
	return super;
}

int
main(void)
{
	unsigned int supersum = 0;

	for (size_t i = 0; i < 512; i++) {
		supersum += super();
	}
	printf("super %u\n", supersum);
	if (supersum != 1486417920U) {
		return 1;
	}
	return 0;
}

/* basic_ymd_get_wday.c ends here */