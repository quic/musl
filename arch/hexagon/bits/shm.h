#define SHMLBA 4096

struct shmid_ds {
	struct ipc_perm shm_perm;
	size_t shm_segsz;
	long shm_atime;
	long shm_dtime;
	long shm_ctime;
	pid_t shm_cpid;
	pid_t shm_lpid;
	unsigned short shm_nattch;
	unsigned long __pad1;
	unsigned long __pad2;
	unsigned long __pad3;
};

struct shminfo {
	unsigned long shmmax, shmmin, shmmni, shmseg, shmall, __unused[4];
};

struct shm_info {
	int __used_ids;
	unsigned long shm_tot, shm_rss, shm_swp;
	unsigned long __swap_attempts, __swap_successes;
};
