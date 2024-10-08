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
 * Min and Max return A if B is NaN, or B if A is NaN
 * Otherwise, they return the smaller value
 *
 * If values are equal, we want to favor -0.0 for min and +0.0 for max.
 */

/*
 * Compares always return false for NaN
 * if (isnan(A)) A = B; if (A > B) A = B will only trigger at most one of those options.
 */
	.text
	.global fmin
	.type fmin,@function
	.p2align 5
fmin:
	{
		p0 = dfclass(A,#0x10)		// If A is a number
		p1 = dfcmp.gt(A,B)		// AND B > A, don't swap
		ATMP = A
	}
	{
		if (p0) A = B			// if A is NaN use B
		if (p1) A = B			// gt is always false if either is NaN
		p2 = dfcmp.eq(A,B)		// if A == B
		if (!p2.new) jumpr:t r31
	}
	/* A == B, return A|B to select -0.0 over 0.0 */
	{
		A = or(ATMP,B)
		jumpr r31
	}
END(__hexagon_mindf3)
