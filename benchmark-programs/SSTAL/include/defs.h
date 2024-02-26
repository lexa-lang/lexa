#include <stdlib.h>
#include <longjmp.h>
#include <stack_pool.h>

typedef struct {
  mp_jmpbuf_t *ctx_jb;
  void* sp_backup;
  mp_jmpbuf_t *rsp_jb;
} exchanger_t;

typedef enum {
    SINGLESHOT = 1 << 0,
    MULTISHOT = 1 << 1,
    TAIL = 1 << 2,
    ABORT = 1 << 3
} handler_mode_t;

typedef struct {
  const handler_mode_t mode;
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

extern intptr_t ret_val;

#define SWITCH_SP(sp) \
    __asm__ ( \
        "movq %0, %%rsp\n\t" \
        :: "r"(sp) : "rsp" \
    )

// This function is used in place of setjmp, and therefore avoids the setjmp's returns_twice attribute from
// preventing optimizations. Being a setjmp-like function, we need to ensure that the caller-saved
// registers are saved by the prologue, so we use the noinline attribute to prevent inlining.
__attribute__((noinline))
int64_t save_switch_and_run(mp_jmpbuf_t* jb, void* sp, HandlerFuncType func, const intptr_t* const env, exchanger_t* exc, int64_t arg) {
    __asm__ (
        "movq    %1,  0(%0)      \n\t"
        "movq    %%rbx,  8(%0)    \n\t"
        "leaq    (%%rsp), %1      \n\t"
        "movq    %1, 16(%0)    \n\t"
        "movq    %%rbp, 24(%0)    \n\t"
        "movq    %%r12, 32(%0)    \n\t"
        "movq    %%r13, 40(%0)    \n\t"
        "movq    %%r14, 48(%0)    \n\t"
        "movq    %%r15, 56(%0)    \n\t"
        :: "r" (jb), "r" (&&cont)
    );
    sp = (void*)((uintptr_t)sp & ~((uintptr_t)0xF)); // Align sp down to the nearest 16-byte boundary
    __asm__ (
        "movq %0, %%rsp\n\t"
        :: "r"(sp) : "rsp"
    );
    func(env, exc, arg);
cont:
    return ret_val;
}

__attribute__((noinline))
int64_t save_and_restore(mp_jmpbuf_t* jb1, mp_jmpbuf_t* jb2) {
    __asm__ (
        "movq    %1,  0(%0)      \n\t"
        "movq    %%rbx,  8(%0)    \n\t"
        "leaq    (%%rsp), %1      \n\t"
        "movq    %1, 16(%0)    \n\t"
        "movq    %%rbp, 24(%0)    \n\t"
        "movq    %%r12, 32(%0)    \n\t"
        "movq    %%r13, 40(%0)    \n\t"
        "movq    %%r14, 48(%0)    \n\t"
        "movq    %%r15, 56(%0)    \n\t"
        :: "r" (jb1), "r" (&&cont)
    );
    __asm__ (
        "movq  8(%0), %%rbx    \n\t"
        "movq 16(%0), %%rsp    \n\t"
        "movq 24(%0), %%rbp    \n\t"
        "movq 32(%0), %%r12    \n\t"
        "movq 40(%0), %%r13    \n\t"
        "movq 48(%0), %%r14    \n\t"
        "movq 56(%0), %%r15    \n\t"
        "jmpq *(%0)            \n\t"
        :: "r" (jb2)
    );
cont:
    return ret_val;
}

#define HANDLE_ONE(body, mode, func, env) \
    ({ \
    intptr_t out; \
    handler_def_t defs[1] = {{mode, (void*)func}}; \
    if (mode == TAIL) { \
        handler_t *stub = &(handler_t){defs, env, NULL}; \
        out = body(stub); \
    } else { \
        exchanger_t exc; \
        mp_jmpbuf_t ctx_jb; \
        exc.ctx_jb = &ctx_jb; \
        handler_t *stub = &(handler_t){defs, env, &exc}; \
        if (mode == MULTISHOT || mode == SINGLESHOT) { \
            char* new_sp = get_stack(); \
            if (mp_setjmp(exc.ctx_jb) == 0) { \
                SWITCH_SP(new_sp); \
                body(stub); \
                __builtin_unreachable(); \
            } \
            free_stack(new_sp); \
        } else { \
            if (mp_setjmp(exc.ctx_jb) == 0) { \
                body(stub); \
                __builtin_unreachable(); \
            } \
        } \
        out = (intptr_t)ret_val; \
    } \
    out; \
    })

#define HANDLE_TWO(body, mode1, func1, mode2, func2, env) \
    ({ \
    intptr_t out; \
    handler_def_t defs[2] = {{mode1, (void*)func1}, {mode2, (void*)func2}}; \
    if ((mode1 | mode2) == TAIL) { \
        handler_t *stub = &(handler_t){defs, env, NULL}; \
        out = body(stub); \
    } else { \
        exchanger_t exc; \
        mp_jmpbuf_t ctx_jb; \
        exc.ctx_jb = &ctx_jb; \
        handler_t *stub = &(handler_t){defs, env, &exc}; \
        if ((mode1 | mode2 & MULTISHOT) || (mode1 | mode2 & SINGLESHOT)) { \
            char* new_sp = get_stack(); \
            if (mp_setjmp(exc.ctx_jb) == 0) { \
                SWITCH_SP(new_sp); \
                body(stub); \
                __builtin_unreachable(); \
            } \
            free_stack(new_sp); \
        } else { \
            if (mp_setjmp(exc.ctx_jb) == 0) { \
                body(stub); \
                __builtin_unreachable(); \
            } \
        } \
        out = (intptr_t)ret_val; \
    } \
    out; \
    })

#define RAISE(stub, index, arg) \
    ({ \
    intptr_t out; \
    switch (stub->defs[index].mode) { \
        case SINGLESHOT: \
        case MULTISHOT: {\
            stub->exchanger->rsp_jb = (mp_jmpbuf_t*)xmalloc(sizeof(mp_jmpbuf_t)); \
            out = save_switch_and_run(stub->exchanger->rsp_jb, stub->exchanger->ctx_jb->reg_sp, ((HandlerFuncType)stub->defs[index].func), stub->env, stub->exchanger, arg); \
            break; \
        } \
        case TAIL: \
            out = ((TailHandlerFuncType)stub->defs[index].func)(stub->env, arg); \
            break; \
        case ABORT: \
            SWITCH_SP(stub->exchanger->ctx_jb->reg_sp); \
            ((HandlerFuncType)stub->defs[index].func)(stub->env, stub->exchanger, arg); \
            __builtin_unreachable(); \
    }; \
    out; \
    })

// Handler preamble backup the stack pointer of the resumption
// into a special field in the exchanger.
// When resuming, the stack is copied from this stack pointer.
#define HANDLER_PREAMBLE(exc) \
    ((exchanger_t*)exc)->sp_backup = ((exchanger_t*)exc)->rsp_jb->reg_sp

#define THROW(rsp_jb, rsp_sp, exc, arg) \
    ({ \
    ret_val = arg; \
    intptr_t out; \
    mp_jmpbuf_t new_ctx_jb; \
    exc->ctx_jb = &new_ctx_jb; \
    char* new_sp = dup_stack((char*)rsp_sp); \
    rsp_jb->reg_sp = (void*)new_sp; \
    out = save_and_restore(exc->ctx_jb, rsp_jb); \
    free_stack(new_sp); \
    out; \
    })

#define FINAL_THROW(rsp_jb, rsp_sp, exc, arg) \
    ({ \
    ret_val = arg; \
    intptr_t out; \
    mp_jmpbuf_t new_ctx_jb, *rsp_jb; \
    ((exchanger_t*)exc)->ctx_jb = &new_ctx_jb; \
    rsp_jb = ((exchanger_t*)exc)->rsp_jb; \
    rsp_jb->reg_sp = (void*)((exchanger_t*)exc)->sp_backup; \
    out = save_and_restore(((exchanger_t*)exc)->ctx_jb, ((exchanger_t*)exc)->rsp_jb); \
    free(rsp_jb); \
    out; \
    })

int64_t mathAbs(int64_t a) {
  return labs(a);
}

#define readInt() atoi(argv[1])
#define printInt(x) printf("%ld\n", x)