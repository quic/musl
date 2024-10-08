// Copied from kernel-headers-3.19

#define __statfs_word unsigned long

struct statfs {
	__statfs_word f_type;
	__statfs_word f_bsize;
	__statfs_word f_blocks __attribute__((aligned(8)));
	int __pad0;
	__statfs_word f_bfree __attribute__((aligned(8)));
	int __pad1;
	__statfs_word f_bavail __attribute__((aligned(8)));
	int __pad2;
	__statfs_word f_files __attribute__((aligned(8)));
	int __pad3;
	__statfs_word f_ffree __attribute__((aligned(8)));
	int __pad4;
	fsid_t f_fsid;
	__statfs_word f_namelen;
	__statfs_word f_frsize;
	__statfs_word f_flags;
	__statfs_word f_spare[4];
}__attribute__((aligned(8)));

