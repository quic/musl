#include <setjmp.h>
#include <signal.h>
#include "syscall.h"
#include "pthread_impl.h"

_Noreturn void siglongjmp(sigjmp_buf buf, int ret)
{
#if defined (__hexagon__)
	// TODO - The following two lines were added
	//        Figure out why they weren't in the original source
	if (buf->__fl)
		pthread_sigmask(SIG_SETMASK, (sigset_t *)buf->__ss, NULL);
#endif
	longjmp(buf, ret);
}
