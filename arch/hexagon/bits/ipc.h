// Copied from kernel headers-3.19/include/linux/ipc.h

struct ipc_perm
{
	key_t __ipc_perm_key;
	uid_t uid;
	gid_t gid;
	uid_t cuid;
	gid_t cgid;
	mode_t mode;
	unsigned short seq;
};

#define IPC_64 0x100
