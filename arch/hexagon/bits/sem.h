struct semid_ds {
	struct ipc_perm sem_perm;
	unsigned long sem_otime;
	unsigned long __unused1;
	unsigned long sem_ctime;
	unsigned long __unused2;
	unsigned short sem_nsems;
	long __unused3;
	long __unused4;
};
