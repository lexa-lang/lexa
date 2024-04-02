#define DEBUG 1
#ifdef DEBUG
#define DEBUG_ATTRIBUTE __attribute__((noinline))
#else
#define DEBUG_ATTRIBUTE
#endif

#ifdef DEBUG
#define DEBUG_CODE(block) block
#else
#define DEBUG_CODE(block)
#endif