#include <stdlib.h>
#include <longjmp.h>
#include <stack_pool.h>

typedef struct {
  mp_jmpbuf_t *ctx_jb;
  mp_jmpbuf_t *rsp_jb;
} exchanger_t;

typedef enum {
    SINGLESHOT = 0,
    MULTISHOT,
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

#define xmalloc(size) ({                \
    void *_ptr = malloc(size);          \
    if (_ptr == NULL) {                 \
        exit(EXIT_FAILURE);             \
    }                                   \
    _ptr;                               \
})

typedef void(*HandlerFuncType)(const intptr_t* const, exchanger_t*, int64_t);
typedef int64_t(*TailHandlerFuncType)(const intptr_t* const, int64_t);

#define HANDLE(stub, body) \
    ({ \
    intptr_t out; \
    mp_jmpbuf_t ctx_jb; \
    stub->exchanger->ctx_jb = &ctx_jb; \
    char* new_sp = get_stack(); \
    if (mp_setjmp(stub->exchanger->ctx_jb) == 0) { \
        __asm__ ( \
            "movq %0, %%rsp\n\t" \
            :: "r"(new_sp) \
        ); \
        body(stub); \
        __builtin_unreachable(); \
    } else { \
        out = (intptr_t)ret_val; \
    } \
    free_stack(new_sp); \
    out; \
    })

#define RAISE(stub, index, arg) \
    ({ \
    intptr_t out; \
    switch (stub->defs[index].behavior) { \
        case SINGLESHOT: \
        case MULTISHOT: {\
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
        } \
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

#define THROW(rsp_jb, rsp_sp, exc, arg) \
    ({ \
    ret_val = arg; \
    intptr_t out; \
    mp_jmpbuf_t new_ctx_jb; \
    exc->ctx_jb = &new_ctx_jb; \
    char* new_sp = dup_stack((char*)rsp_sp); \
    rsp_jb->reg_sp = (void*)new_sp; \
    if (mp_setjmp(exc->ctx_jb) == 0) { \
        mp_longjmp(rsp_jb); \
        __builtin_unreachable(); \
    } else { \
        out = (intptr_t)ret_val; \
    } \
    free_stack(new_sp); \
    out; \
    })

#define FINAL_THROW(rsp_jb, rsp_sp, exc, arg) \
    ({ \
    ret_val = arg; \
    intptr_t out; \
    mp_jmpbuf_t new_ctx_jb; \
    exc->ctx_jb = &new_ctx_jb; \
    rsp_jb->reg_sp = (void*)rsp_sp; \
    if (mp_setjmp(exc->ctx_jb) == 0) { \
        mp_longjmp(rsp_jb); \
        __builtin_unreachable(); \
    } else { \
        out = (intptr_t)ret_val; \
    } \
    out; \
    })

int64_t mathAbs(int64_t a) {
  return labs(a);
}