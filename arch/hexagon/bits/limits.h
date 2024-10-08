#if defined(_POSIX_SOURCE) || defined(_POSIX_C_SOURCE) \
 || defined(_XOPEN_SOURCE) || defined(_GNU_SOURCE) || defined(_BSD_SOURCE)
#define LONG_BIT 32
#endif

// Page size on Hexagon Linux is 64K
#define PAGE_SIZE 0x10000

#define LONG_MAX  0x7fffffffL
#define LLONG_MAX  0x7fffffffffffffffLL
