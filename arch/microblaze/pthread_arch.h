static inline struct pthread *__pthread_self()
{
	struct pthread *self;
	__asm__ ("ori %0, r21, 0" : "=r" (self) );
	return self;
}

#define MC_PC regs.pc
