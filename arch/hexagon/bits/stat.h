// Copied from kernel-headers-3.19
// ... and modified to avoid compiler errors (see #if 0's)

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

        struct timespec st_atim;       /* Time of last access.  */
        struct timespec st_mtim;       /* Time of last modification.  */
        struct timespec st_ctim;       /* Time of last status change.  */
	int __unused[2];
};

