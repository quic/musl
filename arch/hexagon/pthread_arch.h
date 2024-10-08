
// Hexagon supports variant 2 TLS.
static inline struct pthread *__pthread_self()
{
  struct pthread *tp;
  __asm__ ( "%0 = ugp" : "=r"(tp));
  return tp;
}

#define TP_ADJ(p) (p)

#define CANCEL_REG_IP 43

#define MC_PC pc
