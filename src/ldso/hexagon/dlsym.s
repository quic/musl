//  From dlsym.c
//  void *__dlsym(void *restrict, const char *restrict, void *restrict);
//
//  void *dlsym(void *restrict p, const char *restrict s)
//  {
//  	return __dlsym(p, s, 0);
//  }

.global dlsym
.hidden __dlsym
.type dlsym,%function
dlsym:
	{ r2 = #0
	  jump __dlsym }
.size dlsym, .-dlsym
