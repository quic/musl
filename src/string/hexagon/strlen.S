/* HEXAGON assembly optimized strlen */
/* V4 optimz by EJP */


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

// FUNCTION: strcmp
HEXAGON_OPT_FUNC_BEGIN strlen

//  Replaces the standard library function strlen.
//  Checks for the alignment of the string.  If 8 aligned, jumps
//  to an optimized loop that compares in 8 byte blocks

	{
		r4 = memub(r0)
		p1 = bitsclr(r0,#7)
		if (!p1.new) jump:nt .Lnot_aligned
		r2 = #0
	}
	{
		p0 = cmp.eq(r4,#0)
		if (p0.new) jump:nt .Lzero
	}
	// COMBINE THESE PACKETS AFTER BRANCH/JUMP MERGING
	{
		if (!p0) r5:4 = memd(r0+r2<<#0)
		r7:6 = #0
		if (!p0) r2 = add(r2,#8)
	}
	.falign
1:
	{
		p0 = any8(vcmpb.eq(r5:4,r7:6))		// any old bytes zero?
		if (!p0.new) r5:4 = memd(r0+r2<<#0)	// if not, get new bytes
		if (!p0.new) jump:t 1b			// if not, loop
		if (!p0.new) r2 = add(r2,#8)		// if not, add to length
	}
	p0 = vcmpb.eq(r5:4,r7:6)			// what bytes are non-zero?
	r4 = p0						// move to reg
	{
		r4 = ct0(r4)				// first zero byte
		r2 = add(r2,#-8)			// adj r2 back
	}
	{
		r0 = add(r2,r4)				// length
		jumpr r31				// return
	}

	.falign
.Lzero:
	{
		r0 = #0
		jumpr r31
	}

	.falign
.Lnot_aligned:
	// OK, we want to loop one char at a time
	// UNTIL we get to an aligned doubleword,
	// then we can jump back to the fast code
	{
		r1 = add(r0,r2)
		p1 = cmp.eq(r4,#0)
		if (p1.new) jump:nt .Lna_found_zero
	}
	{
		p0 = bitsclr(r1,#7)
		if (!p0.new) jump:nt .Lnot_aligned	// not aligned...
		if (!p0.new) r4 = memub(r1+#1)		// get next
		if (!p0.new) r2 = add(r2,#1)		// increment counter
	}
	{
		r5:4 = memd(r0+r2<<#0)			// we are aligned now
		r7:6 = #0				// clear r7:6
		r2 = add(r2,#8)				// advance count
		jump 1b					// jump to aligned loop directly
	}
	.falign
.Lna_found_zero:
	{
		r0 = r2					// adjust back one
		jumpr r31
	}
HEXAGON_OPT_FUNC_FINISH strlen
