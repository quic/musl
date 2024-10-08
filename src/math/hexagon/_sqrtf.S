/******************************************************************
# Copyright (c) $Date$ QUALCOMM INCORPORATED.
# All Rights Reserved.
# $Revision$
# Modified by QUALCOMM INCORPORATED on $Date$
******************************************************************/


	.macro FUNCTION_BEGIN name
	.text
	.p2align 4
	.globl \name
	.type  \name, @function
\name:
	.endm

	.macro FUNCTION_END name
	.size  \name, . - \name
	.endm

#define RIN r0
#define S r0
#define H r1
#define D r2
#define E r3
#define HALF r4
#define R r5

FUNCTION_BEGIN __hexagon_sqrtf
  {
    E,p0 = sfinvsqrta(RIN)
    R = sffixupr(RIN)
    HALF = ##0x3f000000   // 0.5
    r1:0 = combine(#0,#0)   // clear S/H
  }
  {
    S += sfmpy(E,R):lib   // S0
    H += sfmpy(E,HALF):lib    // H0
    D = HALF
    E = R
  }
  {
    D -= sfmpy(S,H):lib   // d0
    p1 = sfclass(R,#1)    // is zero?
    //E -= sfmpy(S,S):lib   // e0
  }
  {
    S += sfmpy(S,D):lib   // S1
    H += sfmpy(H,D):lib   // H1
    D = HALF
    E = R
  }
  {
    D -= sfmpy(S,H):lib   // d0
    E -= sfmpy(S,S):lib   // e0
  }
  {
    S += sfmpy(H,E):lib   // S2
    H += sfmpy(H,D):lib   // H2
    D = HALF
    E = R
  }
  {
    //D -= sfmpy(S,H):lib   // d2
    E -= sfmpy(S,S):lib   // e2
    if (p1) r0 = or(r0,R)     // sqrt(-0.0) = -0.0
  }
#if (__HEXAGON_ARCH__ == 61)
    S += sfmpy(H,E,p0):scale  // S3
    jumpr r31
#else
  {
    S += sfmpy(H,E,p0):scale  // S3
    jumpr r31
  }
#endif

FUNCTION_END __hexagon_sqrtf

