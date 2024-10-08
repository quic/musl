struct k_sigaction {
	void (*handler)(int);
	unsigned long flags;
	void (*restorer)(void);
	sigset_t mask;
};
void __restore(), __restore_rt();
