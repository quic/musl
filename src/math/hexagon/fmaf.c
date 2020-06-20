#include <math.h>

float fmaf(float x, float y, float z)
{
	__asm__ ("%[z]+=sfmpy(%[x], %[y])"
                 : [z]"+r"(z) : [x]"r"(x), [y]"r"(y));
	return z;
}
