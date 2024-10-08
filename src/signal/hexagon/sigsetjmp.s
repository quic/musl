	.text
	.globl	sigsetjmp
	.balign 4
	.type	sigsetjmp,@function
sigsetjmp:
	{
		p0 = cmp.eq(r1, #0)
		r16 = r0
		memd(r29 + #-16) = r17:16
		allocframe(#8)
	}
	{
		if (p0) jump 1f
		if (!p0) r2 = add(r16, #68)
		memw(r16+#64) = r1
	}
	{
		call pthread_sigmask
		r1:0 = combine(#0, #2)
	}
1:
	{
		r0 = r16
		r17:16 = memd(r29 + #0)
		deallocframe
	}
	{
		jump setjmp
	}
	.size	sigsetjmp, .-sigsetjmp


.weak	__sigsetjmp
.set __sigsetjmp, sigsetjmp
