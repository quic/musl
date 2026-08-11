/* Shadow-call-stack entry setup.
 *
 * When libc is compiled with -fsanitize=shadow-call-stack (the "scs" multilib),
 * the SCS register holds a pointer into a shadow stack that grows up, and every
 * instrumented prologue stores its return address through it. Nothing has set
 * that register when the kernel transfers control here, so the first
 * instrumented function reached from this entry point -- __libc_start_main for
 * _start, or _dlstart_c/__dls2 for the dynamic linker -- would store through a
 * garbage pointer and SEGV before main() is ever reached.
 *
 * Point the register at a static, per-entry-point shadow stack before anything
 * else runs. Each startup object that includes this header (crt1, Scrt1, rcrt1,
 * dlstart) gets its own hidden buffer, named after its START symbol so two of
 * them can coexist in one link. The dynamic linker's buffer is only used until
 * it jumps to the program's entry point, which installs its own.
 *
 * The register defaults to r18, matching the compiler's default (see
 * HexagonSubtarget::getSCSPReg()); override with -D__HEXAGON_SCS_REG=rN here and
 * -mscs-reg=rN for the instrumented code. Setting it is harmless when libc is
 * not instrumented, but the buffer is not worth carrying, so this is all
 * conditional on the same __HEXAGON_SCS_THREADS__ that gates the per-thread
 * shadow stacks in pthread_create.c.
 */
#ifdef __HEXAGON_SCS_THREADS__

#ifndef __HEXAGON_SCS_REG
#define __HEXAGON_SCS_REG r18
#endif
#define __SCS_STR_(x) #x
#define __SCS_STR(x) __SCS_STR_(x)

/* 1 MiB = 256K nested frames, same size as the scs multilib's crt1. */
#define __SCS_SYM "__scs_shadow_stack" START
#define __SCS_SETUP \
	"       " __SCS_STR(__HEXAGON_SCS_REG) " = add(pc,##" __SCS_SYM "@pcrel)\n"
#define __SCS_BUFFER \
	".bss \n" \
	".hidden " __SCS_SYM " \n" \
	".p2align 3 \n" \
	__SCS_SYM ": .space (1<<20) \n" \
	".size " __SCS_SYM ", (1<<20)\n" \
	".text \n"

#else
#define __SCS_SETUP ""
#define __SCS_BUFFER ""
#endif

__asm__(
".weak _DYNAMIC \n"
".hidden _DYNAMIC \n"
".text \n"
".global " START " \n"
".type " START ", %function \n"
START ": \n"
__SCS_SETUP
"                                       // Find _DYNAMIC\n"
"       jump 1f\n"
".word  _DYNAMIC - .\n"
"1:     r2 = pc\n"
"       r2 = add(r2, #-4)\n"
"       r1 = memw(r2)\n"
"       r1 = add(r2, r1)\n"
"	r30 = #0			// Signals the end of backtrace\n"
"	r31 = #0\n"
"	r0 = r29			// Pointer to argc/argv\n"
"	r29 = and(r29, #-16)		// Align\n"
"	memw(r29+#-8) = r29\n"
"	r29 = add(r29, #-8)\n"
"	call " START "_c \n"
".size " START ", .-" START "\n"
__SCS_BUFFER
);
