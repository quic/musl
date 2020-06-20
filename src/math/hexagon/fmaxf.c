#include <math.h>

float fmaxf(float x, float y)
{
	__asm__ ("%[x]=sfmax(%[x], %[y])"
                : [x]"+r"(x) : [y]"r"(y));
	return x;
}
