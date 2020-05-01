struct ipc_perm {
	int __ipc_perm_key;
	int uid;
	int gid;
	int cuid;
	int cgid;
	mode_t mode;
	unsigned short __ipc_perm_seq;
};

