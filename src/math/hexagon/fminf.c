#include <math.h>

float fminf(float x, float y)
{
	__asm__ ("%[x]=sfmin(%[x], %[y])"
                : [x]"+r"(x) : [y]"r"(y));
	return x;
}
