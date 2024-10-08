#include <endian.h>

#if __BYTE_ORDER == __LITTLE_ENDIAN
#define ENDIAN_SUFFIX "el"
#else
#define ENDIAN_SUFFIX ""
#endif

#define FP_SUFFIX ""

#define LDSO_ARCH "hexagon" ENDIAN_SUFFIX FP_SUFFIX

#define TPOFF_K 0

#define REL_SYMBOLIC    R_HEX_32
#define REL_GOT         R_HEX_GLOB_DAT
#define REL_PLT         R_HEX_JMP_SLOT
#define REL_RELATIVE    R_HEX_RELATIVE
#define REL_COPY        R_HEX_COPY
#define REL_DTPMOD      R_HEX_DTPMOD_32
#define REL_TPOFF       R_HEX_TPREL_32
#define REL_DTPOFF      R_HEX_DTPREL_32

#if 0
// TODO - Not sure if these are needed
#define REL_DTPOFF      R_HEX_??
#define REL_TLSDESC     R_HEX_??
#define REL_TPOFF_NEG   R_HEX_??
#define REL_OFFSET      R_HEX_??
#define REL_OFFSET32    R_HEX_??
#define REL_SYM_OR_REL  R_HEX_??
#endif

#define CRTJMP(pc,sp) __asm__ __volatile__( \
	"r29 = %1 ; jumpr %0" : : "r"(pc), "r"(sp) : "memory" )
