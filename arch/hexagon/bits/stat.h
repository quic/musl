// Copied from kernel-headers-3.19

struct stat {
        dev_t   st_dev;         /* Device.  */
        unsigned long long   st_ino;
        unsigned int    st_mode;        /* File mode.  */
        unsigned int    st_nlink;       /* Link count.  */
        unsigned int    st_uid;         /* User ID of the file's owner.  */
        unsigned int    st_gid;         /* Group ID of the file's group. */
        unsigned long long   st_rdev;        /* Device number, if device.  */
        unsigned long   __pad1;
        long long       st_size;
        blksize_t        st_blksize;     /* Optimal block size for I/O.  */
        int __pad2;
        long long           st_blocks;
	struct {
		long tv_sec;
		long tv_nsec;
	} __st_atim32, __st_mtim32, __st_ctim32;
	unsigned __unused[2];
	struct timespec st_atim;
	struct timespec st_mtim;
	struct timespec st_ctim;
};
