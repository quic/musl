// Example call
// __syscall(nr,  u,  v,  w,  x,  y,  z)
//           r0  r1  r2  r3  r4  r5   stack
.global __syscall
.hidden __syscall
.type __syscall,@function
__syscall:
	{
		r6 = r0
		r1:0 = combine(r2, r1)
		r3:2 = combine(r4, r3)
		r7 = memw(r29 + #0)
	}
	{
		r5:4 = combine(r7, r5)
	}
	trap0(#1)
	jumpr r31
