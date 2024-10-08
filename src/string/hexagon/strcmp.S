/* HEXAGON assembly optimized strcmp */
/* optimized by ctabony and EJP */


	.macro HEXAGON_OPT_FUNC_BEGIN name
	.text
	.p2align 5
	.globl \name
	.type  \name, @function
\name:
	.endm

	.macro HEXAGON_OPT_FUNC_FINISH name
	.size  \name, . - \name
	.endm

/* V4 optimz by EJP */
// FUNCTION: strcmp
HEXAGON_OPT_FUNC_BEGIN strcmp

//  Replaces the standard library function strcmp.
//  Checks for the alignment of the two strings.  If both are 8 aligned, jumps
//  to an optimized loop that compares in 8 byte blocks, else compares byte by
//  byte.  While checking alignment, checks whether the first bytes differ and
//  if so, returns an appropriate value.
//  inputs:
//  r0 = &s1[0]
//  r1 = &s2[0]
//  outputs:
//  r0 < 0 if s1 < s2, 0 if s1 == s2, r0 > 0 if s1 > s2

//  check whether both strings are 8-aligned
	{
		p0 = bitsclr(r0,#7)		//  are r0 and r1 aligned?
		p0 = bitsclr(r1,#7)		//  are r0 and r1 aligned?
		if (p0.new) r3:2 = memd(r0)	//  block of s1
		if (p0.new) r5:4 = memd(r1)	//  block of s2
	}
	{
		if (!p0) jump 2f	//  if not aligned, compare byte by byte
		r6 = #0
		r9:8 = #0
	}
//  compare 8 bytes at a time
	.falign
//  unroll loop 3x:
0:
//  1st iteration
	{
		p0 = any8(vcmpb.eq(r5:4,r9:8))	//  find end of s2
		p1 = cmp.eq(r3:2,r5:4)		//  see if s1 == s2 so far
		r6 = add(r6,#8)
	}
	{
		p0 = or(p0,!p1)
		if (p0.new) jump:t 1f		//  if end not found and no differences, loop
		if (!p0.new) r3:2 = memd(r0+r6<<#0)	//  if looping, load next vals
		if (!p0.new) r5:4 = memd(r1+r6<<#0)	//  if looping, load next vals
	}
//  2nd iteration
	{
		p0 = any8(vcmpb.eq(r5:4,r9:8))	//  find end of s2
		p1 = cmp.eq(r3:2,r5:4)		//  see if s1 == s2 so far
		r6 = add(r6,#8)
	}
	{
		p0 = or(p0,!p1)
		if (p0.new) jump:t 1f		//  if end not found and no differences, loop
		if (!p0.new) r3:2 = memd(r0+r6<<#0)	//  if looping, load next vals
		if (!p0.new) r5:4 = memd(r1+r6<<#0)	//  if looping, load next vals
	}
//  3rd iteration
	{
		p0 = any8(vcmpb.eq(r5:4,r9:8))	//  find end of s2
		p1 = cmp.eq(r3:2,r5:4)		//  see if s1 == s2 so far
		r6 = add(r6,#8)
	}
	{
		p0 = or(p0,!p1)
		if (!p0.new) jump:t 0b		//  if end not found and no differences, loop
		if (!p0.new) r3:2 = memd(r0+r6<<#0)	//  if looping, load next vals
		if (!p0.new) r5:4 = memd(r1+r6<<#0)	//  if looping, load next vals
	}
//  end of loop
1:
	{
		p0 = vcmpb.eq(r3:2,#0)		//  zeros
		p1 = vcmpb.eq(r3:2,r5:4)	//  diffs
		r6 = add(r6,#-8)
	}
	{
		r4 = p0
		r5 = p1
	}
	{
		r0 = add(r0,r6)
		r1 = add(r1,r6)
		r4 = ct0(r4)	//  zeros
		r5 = ct1(r5)	//  diffs
	}
	{
		if(!p0.new) r2 = memub(r0+r5<<#0)	//  first diff byte
		if(!p0.new) r3 = memub(r1+r5<<#0)	//  first diff byte
		p0 = cmp.gtu(r5,r4)		//  zero has lower index?
		r0 = #0
	}
	{
		if (!p0) r0 = sub(r2,r3)	//  if not, return diff
		jumpr r31			//  return
	}
//  compare byte by byte
	.falign
2:
	{
		r2 = memub(r0)	//  load the first byte of s1
		r3 = memub(r1)	//  and s2
		r4 = add(r0,#1)	//  move pointers out of the return register
		r5 = add(r1,#1)
	}
	.falign
3:
	{
		p0 = cmp.eq(r2,#0)	//  see if s1 ends at this byte
		p1 = cmp.eq(r2,r3)	//  see if s1 and s2 are equal so far
		r0 = sub(r2,r3)		//  see if s1 > s2
	}
	{
		p0 = or(p0,!p1)			//  strings differ or end found?
		if (!p0.new) jump:t 3b		//  if not, loop again
		if (!p0.new) r2 = memub(r4++#1)	//  load the next byte of s1
		if (!p0.new) r3 = memub(r5++#1)	//  load the next byte of s2
	}
	{
		jumpr r31	//  all done, r0 has return value
	}

HEXAGON_OPT_FUNC_FINISH strcmp
