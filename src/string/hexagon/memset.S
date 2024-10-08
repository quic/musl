/* HEXAGON assembly optimized memset */
// Replaces the standard library function memset


        .macro HEXAGON_OPT_FUNC_BEGIN name
        .text
        .p2align 4
        .globl \name
        .type  \name, @function
\name:
        .endm

        .macro HEXAGON_OPT_FUNC_FINISH name
        .size  \name, . - \name
        .endm

//-----------------------------------------------------------------------------
// void *memset(void* ptr, int value, size_t n)
#define ptr               r0
#define value             r1
#define n                 r2
#define cur_ptr           r3
#define splat_reg         r6
#define splat_pair        r7:6
#define loop_count        r8

HEXAGON_OPT_FUNC_BEGIN memset
	// if (n == 0) return ptr;
	{
		p0 = cmp.eq(n, #0)
		if (p0.new) jumpr:nt lr
		splat_reg = vsplatb(value)
		cur_ptr = ptr
	}
	// If less than 32 bytes, set a byte at a time and return.
	{
		r7 = r6
		p0 = cmp.gtu(n, #32)
		if (p0.new) jump:t .Lskip_byte_loop
        }
        // Set up the byte loop to store two bytes in a single iteration.
        {
                n = lsr(n, #1)
                p0 = tstbit(n, #0)
                if (p0.new) memb(cur_ptr++#1) = value
        }
        {
                p0 = cmp.eq(n, #0)
                if (p0.new) jump:nt .Lbyte_end
                loop0(.Lbyte_loop, n)
        }
	.falign
.Lbyte_loop:
	{
		memb(cur_ptr+#1) = value
		memb(cur_ptr++#2) = value
	}:endloop0
.Lbyte_end:
	{
		jumpr lr
	}
.Lskip_byte_loop:
        // ***************************************************************
        // At this point, we know we have at least 33 bytes, so we don't
        // need to check if there are more bytes at each step
        // ***************************************************************

	// Shortcut for common case of double-word alignment
	// Should benchmark to see if this is a win
	{
		p0 = bitsclr(cur_ptr, #7)
		if (p0.new) jump:t .Lskip_small_accesses
	}

        // Check for byte store
	{
		p0 = tstbit(cur_ptr, #0)
		if (p0.new) n = add(n, #-1)
		if (p0.new) memb(cur_ptr++#1) = splat_reg
	}
        // Check for half-word store
	{
		p0 = tstbit(cur_ptr, #1)
		if (p0.new) n = add(n, #-2)
		if (p0.new) memh(cur_ptr++#2) = splat_reg
	}
        // Check for word store
	{
		p0 = tstbit(cur_ptr, #2)
		if (p0.new) n = add(n, #-4)
		if (p0.new) memw(cur_ptr++#4) = splat_reg
	}
.Lskip_small_accesses:
        // Check for double-word store
	{
		p0 = tstbit(cur_ptr, #3)
		if (p0.new) n = add(n, #-8)
		if (p0.new) memd(cur_ptr++#8) = splat_pair
	}
        // Check for two double-word stores (16-byte alignment)
	{
		p0 = tstbit(cur_ptr, #4)
		if (p0.new) n = add(n, #-16)
		if (p0.new) memd(cur_ptr++#16) = splat_pair
		if (p0.new) memd(cur_ptr+#8) = splat_pair
	}
	// We should now be aligned to a 32-byte (cache line) boundary
	// If we don't have at lease 1 cache line left to do, skip these loops
	{
		r5 = #32
		if (cmp.gtu(r5.new, n)) jump:t .Lskip_dczero_loops
		// Decide if the value to store is zero
		p0 = cmp.eq(value, #0)
		loop_count = lsr(n, #5)
	}
	{
		if (p0) jump .Lskip_nonzero_loop
		loop0(.Lnonzero_loop, loop_count)
	}
	.falign
.Lnonzero_loop:
	{
		dczeroa(cur_ptr)
	}
	{
		memd(cur_ptr++#16) = splat_pair
		memd(cur_ptr+#8) = splat_pair
	}
	{
		memd(cur_ptr++#16) = splat_pair
		memd(cur_ptr+#8) = splat_pair
		n = add(n, #-32)
	}:endloop0
	{
		jump .Lskip_dczero_loops
	}
.Lskip_nonzero_loop:
	{
		loop0(.Lzero_loop, loop_count)
	}
	.falign
.Lzero_loop:
	{
		dczeroa(cur_ptr)
		cur_ptr = add(cur_ptr, #32)
		n = add(n, #-32)
	}:endloop0
.Lskip_dczero_loops:
       // ***************************************************************
       // At this point, we are at the start of the last partial cache line.
       // Therefore, cur_ptr is aligned to a 32-byte address and n < 32.
       // ***************************************************************
       // Check for two double-word stores (16-bytes)
       {
                p0 = tstbit(n, #4)
                if (p0.new) n = add(n, #-16)
                if (p0.new) memd(cur_ptr++#16) = splat_pair
                if (p0.new) memd(cur_ptr+#8) = splat_pair
        }
	// Check for double-word store
        {
                p0 = tstbit(n, #3)
                if (p0.new) n = add(n, #-8)
                if (p0.new) memd(cur_ptr++#8) = splat_pair
        }
	// Check for word store
        {
                p0 = tstbit(n, #2)
                if (p0.new) n = add(n, #-4)
                if (p0.new) memw(cur_ptr++#4) = splat_reg
        }
	// Check for half-word store
        {
                p0 = tstbit(n, #1)
                if (p0.new) n = add(n, #-2)
                if (p0.new) memh(cur_ptr++#2) = splat_reg
        }
	// Check for byte store
#if (__HEXAGON_ARCH__ == 61)
	{
		p0 = tstbit(n, #0)
		if (p0.new) memb(cur_ptr) = splat_reg
	}
	{
		jumpr lr
	}
#else
	{
		p0 = tstbit(n, #0)
		if (p0.new) memb(cur_ptr) = splat_reg
		jumpr lr
	}
#endif
HEXAGON_OPT_FUNC_FINISH memset

