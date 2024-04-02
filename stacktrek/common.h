#define DEBUG 1
#ifdef DEBUG
#define DEBUG_ATTRIBUTE __attribute__((noinline))
#else
#define DEBUG_ATTRIBUTE
#endif