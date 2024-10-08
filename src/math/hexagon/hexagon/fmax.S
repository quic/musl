/*****************************************************************
# Copyright (c) $Date$ QUALCOMM INCORPORATED.
# All Rights Reserved.
# Modified by QUALCOMM INCORPORATED on $Date$
*****************************************************************/

#define A r1:0
#define B r3:2
#define ATMP r5:4


#define END(TAG) .size TAG,.-TAG
/*
 * Max return A if B is NaN, or B if A is NaN
 * Otherwise, they return the bigger value
 *
 * If values are equal, we want to favor -0.0 for min and +0.0 for max.
 */

/*
 * Compares always return false for NaN
 * if (isnan(A)) A = B; if (A > B) A = B will only trigger at most one of those options.
 */
	.text
	.global fmax
	.type fmax,@function
	.p2align 5
fmax:
	{
		p0 = dfclass(A,#0x10)
		p1 = dfcmp.gt(B,A)
		ATMP = A
	}
	{
		if (p0) A = B
		if (p1) A = B
		p2 = dfcmp.eq(A,B)
		if (!p2.new) jumpr:t r31
	}
	/* A == B, return A&B to select 0.0 over -0.0 */
	{
		A = and(ATMP,B)
		jumpr r31
	}
END(fmax)

