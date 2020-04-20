struct stat {
    unsigned long long st_dev;
    unsigned long long st_ino;
    unsigned int st_mode;
    unsigned int st_nlink;
    unsigned int st_uid;
    unsigned int st_gid;
    unsigned long long st_rdev;
    unsigned long __pad1;
    long long st_size;
    unsigned long st_blksize;
    int __pad2;
    long long st_blocks;

    struct timespec st_atim;       /* Time of last access.  */
    struct timespec st_mtim;       /* Time of last modification.  */
    struct timespec st_ctim;       /* Time of last status change.  */

    int __unused[2];
};
