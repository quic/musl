.global __set_thread_area
.type   __set_thread_area,@function
__set_thread_area:
// V61 POPQ errata.
#if __HEXAGON_ARCH__ == 61
	{ ugp = r0
	  r0 = #0 }
	  jumpr r31
#else
	{ ugp = r0
	  r0 = #0
	  jumpr r31 }
#endif
.size __set_thread_area, .-__set_thread_area
