#include <stdlib.h>
#include <longjmp.h>
#include <stack_pool.h>

typedef struct {
  mp_jmpbuf_t *ctx_jb;
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

__attribute__((noinline)) // ensure that caller-saved registers are saved by the prologue
int64_t save_switch_and_run(mp_jmpbuf_t* jb, void* sp, HandlerFuncType func, const intptr_t* const env, exchanger_t* exc, int64_t arg) {
    __asm__ (
        "leaq    (%%rsp), %%rcx      \n\t"
        "movq    %%rax,  0(%%rdi)      \n\t"
        "movq    %%rbx,  8(%%rdi)    \n\t"
        "movq    %%rcx, 16(%%rdi)    \n\t"
        "movq    %%rbp, 24(%%rdi)    \n\t"
        "movq    %%r12, 32(%%rdi)    \n\t"
        "movq    %%r13, 40(%%rdi)    \n\t"
        "movq    %%r14, 48(%%rdi)    \n\t"
        "movq    %%r15, 56(%%rdi)    \n\t"
        :: "D" (jb), "A" (&&cont) : "rcx"
    );
    __asm__ (
        "movq %0, %%rsp\n\t"
        :: "r"(sp) : "rsp"
    );
    func(env, exc, arg);
    __builtin_unreachable();
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
    free(rsp_jb); \
    out; \
    })

int64_t mathAbs(int64_t a) {
  return labs(a);
}

#define readInt() atoi(argv[1])
#define printInt(x) printf("%ld\n", x)