struct semid_ds {
	struct ipc_perm sem_perm;
	unsigned long sem_otime;
	unsigned long sem_otime_high;
	unsigned long sem_ctime;
	unsigned long sem_ctime_high;
	unsigned short sem_nsems;
	long __unused3;
	long __unused4;
};
