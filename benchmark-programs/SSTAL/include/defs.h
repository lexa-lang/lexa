#include <stdlib.h>
#include <longjmp.h>

typedef struct {
  mp_jmpbuf_t *ctx_jb;
  mp_jmpbuf_t *rsp_jb;
} exchanger_t;

typedef enum {
    GENERAL = 0,
    TAIL,
    ABORT
} behaviour_t;

typedef struct {
  const behaviour_t behavior;
  const void *func;
} handler_def_t;
typedef struct {
  const handler_def_t* const defs;
  const intptr_t* env;
  exchanger_t* exchanger;
} handler_t;

typedef struct node {
    int64_t value;
    struct node* next;
} node;

#define xmalloc(size) ({                \
    void *_ptr = malloc(size);          \
    if (_ptr == NULL) {                 \
        exit(EXIT_FAILURE);             \
    }                                   \
    _ptr;                               \
})

typedef void(*HandlerFuncType)(const intptr_t* const, exchanger_t*, int64_t);
typedef int64_t(*TailHandlerFuncType)(const intptr_t* const, int64_t);

#define RAISE(stub, index, arg) \
    ({ \
    intptr_t out; \
    switch (stub->defs[index].behavior) { \
        case GENERAL: \
            stub->exchanger->rsp_jb = (mp_jmpbuf_t*)xmalloc(sizeof(mp_jmpbuf_t)); \
            if (mp_setjmp(stub->exchanger->rsp_jb) == 0) { \
                __asm__ ( \
                    "movq %0, %%rsp\n\t" \
                    :: "r"(stub->exchanger->ctx_jb->reg_sp) \
                ); \
                ((HandlerFuncType)stub->defs[index].func)(stub->env, stub->exchanger, arg); \
                __builtin_unreachable(); \
            } else { \
                out = (int64_t)ret_val; \
            } \
            break; \
        case TAIL: \
            out = ((TailHandlerFuncType)stub->defs[index].func)(stub->env, arg); \
            break; \
        case ABORT: \
            __asm__ ( \
                "movq %0, %%rsp\n\t" \
                :: "r"(stub->exchanger->ctx_jb->reg_sp) \
            ); \
            ((HandlerFuncType)stub->defs[index].func)(stub->env, stub->exchanger, arg); \
            __builtin_unreachable(); \
    }; \
    out; \
    })