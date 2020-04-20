struct ipc_perm {
	int __ipc_perm_key;
	int uid;
	int gid;
	int cuid;
	int cgid;
	unsigned short mode;
	unsigned short __pad1;
	unsigned short __ipc_perm_seq;
};

