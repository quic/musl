// TODO
//   __attribute__((__visibility__("hidden")))
//   ptrdiff_t __tlsdesc_static(), __tlsdesc_dynamic();

// size_t __tlsdesc_static(size_t *a)
// {
// 	return a[1];
// }
.global __tlsdesc_static
.hidden __tlsdesc_static
.type __tlsdesc_static,@function
__tlsdesc_static:
	r0 = memw(r0+#4)
	jumpr r31
.size __tlsdesc_static, .-__tlsdesc_static

.global __tlsdesc_dynamic
.hidden __tlsdesc_dynamic
.type __tlsdesc_dynamic,@function
__tlsdesc_dynamic:
.size __tlsdesc_dynamic, .-__tlsdesc_dynamic
