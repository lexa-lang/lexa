#include <stdlib.h>
#include <stack_pool.h>

#define FAST_SWITCH
#ifdef FAST_SWITCH
typedef struct {
  void*     reg_ip;
  void*     reg_sp;
} jb_t;

#define SEAL_STACK(cont, sp) \
    __asm__ ( \
        "pushq %0\n\t" \
        "movq %%rsp, 0(%1)\n\t" \
        :: "r" (cont), "r" (sp) \
    )

#define UNSEAL_STACK(sp, ret_val) \
    __asm__ ( \
        "movq %0, %%rsp\n\t" \
        "retq\n\t" \
        :: "r" (sp), "a" (ret_val) \
    )

#define SAVE_CONTEXT(jb, cont) \
    __asm__ ( \
        "movq    %1,  0(%0)      \n\t" \
        "leaq    (%%rsp), %1      \n\t" \
        "movq    %1, 8(%0)    \n\t" \
        :: "r" (jb), "r" (&&cont) \
    )

#define RESTORE_CONTEXT(jb) \
    __asm__ ( \
        "movq 8(%0), %%rsp    \n\t" \
        "jmpq *(%0)            \n\t" \
        :: "r" (jb) \
    )

#define FAST_SWITCH_DECORATOR __attribute__((preserve_none))

#else
typedef struct {
  void*     reg_ip;
  int64_t   reg_rbx;
  void*     reg_sp;
  void*     reg_rbp;
  int64_t   reg_r12;
  int64_t   reg_r13;
  int64_t   reg_r14;
  int64_t   reg_r15;
} jb_t;

#define SAVE_CONTEXT(jb, cont) \
    __asm__ ( \
        "movq    %1,  0(%0)      \n\t" \
        "movq    %%rbx,  8(%0)    \n\t" \
        "leaq    (%%rsp), %1      \n\t" \
        "movq    %1, 16(%0)    \n\t" \
        "movq    %%rbp, 24(%0)    \n\t" \
        "movq    %%r12, 32(%0)    \n\t" \
        "movq    %%r13, 40(%0)    \n\t" \
        "movq    %%r14, 48(%0)    \n\t" \
        "movq    %%r15, 56(%0)    \n\t" \
        :: "r" (jb), "r" (&&cont) \
    )

#define RESTORE_CONTEXT(jb) \
    __asm__ ( \
        "movq  8(%0), %%rbx    \n\t" \
        "movq 16(%0), %%rsp    \n\t" \
        "movq 24(%0), %%rbp    \n\t" \
        "movq 32(%0), %%r12    \n\t" \
        "movq 40(%0), %%r13    \n\t" \
        "movq 48(%0), %%r14    \n\t" \
        "movq 56(%0), %%r15    \n\t" \
        "jmpq *(%0)            \n\t" \
        :: "r" (jb) \
    )

#define FAST_SWITCH_DECORATOR

#endif

typedef struct {
  jb_t *ctx_jb;
  void *rsp_sp;
} exchanger_t;

typedef struct {
    void* rsp_sp;
    exchanger_t* exc;
} resumption_t;

typedef enum {
    SINGLESHOT = 1 << 0,
    MULTISHOT = 1 << 1,
    TAIL = 1 << 2,
    ABORT = 1 << 3
} handler_mode_t;

typedef struct {
  handler_mode_t mode;
  void *func;
} handler_def_t;
typedef struct {
  handler_def_t* defs;
  intptr_t* env;
  exchanger_t* exchanger;
} handler_t;

#define xmalloc(size) ({                \
    void *_ptr = malloc(size);          \
    if (_ptr == NULL) {                 \
        exit(EXIT_FAILURE);             \
    }                                   \
    _ptr;                               \
})

// Handler and Body are casted to a type that is not PRESERVE_NONE, although they actually are.
// This avoids the saving caller-saved registers at the callsite that is already done by the context-swtiching function,
// which is(must be) the parent function of the callsite.
typedef void(*HandlerFuncType)(const intptr_t* const, int64_t, exchanger_t*);
typedef void(*BodyFuncType)(handler_t*);
typedef int64_t(*TailHandlerFuncType)(const intptr_t* const, int64_t);
typedef int64_t(*TailBodyFuncType)(handler_t*);

extern intptr_t ret_val;

#define ARG_N(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _, ...) _
#define NARGS(...) ARG_N(__VA_ARGS__, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1)

#define STACK_ALLOC_STRUCT(type, ...) \
    &(type){__VA_ARGS__};
#define STACK_ALLOC_ARRAY(type, ...) \
    (type[]){__VA_ARGS__}; 
// Heap allocate and initialize a variable number of intptr_t
// The compiler is smart enough to eliminate the intermediate stack allocation and memcpy
#define HEAP_ALLOC_STRUCT(type, ...) \
    ({ \
    type st = {__VA_ARGS__}; \
    type* hst = xmalloc(sizeof(type)); \
    memcpy(hst, &st, sizeof(type)); \
    hst; \
    })
#define HEAP_ALLOC_ARRAY(type, ...) \
    ({ \
    type arr[] = {__VA_ARGS__}; \
    type* harr = xmalloc(sizeof(intptr_t)*NARGS(__VA_ARGS__)); \
    memcpy(harr, arr, sizeof(intptr_t)*NARGS(__VA_ARGS__));\
    harr;\
    })

// We are supppose to clobber rsp, but doing so makes the compiler to use rbp to address register spills (eg when saving caller-saved registers)
// This forces us to copy not only the stack but also rsp when copying the stack, creating extra complexity.
// SO, WE DON'T ANNOTATE THE CLOBBERING, AND BE CAREFUL NOT TO USE ANY STACK-STORED VARIABLE BETWEEN
// THIS POINT TO A JMP OR CALL
#define SWITCH_SP(sp) \
    __asm__ ( \
        "movq %0, %%rsp\n\t" \
        :: "r"(sp) \
    )

__attribute__((noinline, naked))
FAST_SWITCH_DECORATOR
int64_t save_switch_and_run_handler(intptr_t* env, int64_t arg, exchanger_t* exc, void* ctx_sp, void** rsp_sp, HandlerFuncType func) {
    __asm__ (
        "movq %%rsp, 0(%%r8)\n\t"
        "movq %%rcx, %%rsp\n\t"
        "jmpq *%%r9\n\t"
        :
    );
}

__attribute__((noinline))
FAST_SWITCH_DECORATOR
int64_t save_switch_and_run_body(jb_t* jb, void* sp, BodyFuncType func, handler_t* stub) {
    SAVE_CONTEXT(jb, cont);
    SWITCH_SP((uintptr_t)sp & ~((uintptr_t)0xF)); // Align sp down to the nearest 16-byte boundary
    func(stub);
cont:
    return ret_val;
}

__attribute__((noinline))
FAST_SWITCH_DECORATOR
int64_t save_and_run_body(jb_t* jb, BodyFuncType func, handler_t* stub) {
    SAVE_CONTEXT(jb, cont);
    func(stub);
cont:
    return ret_val;
}

__attribute__((noinline))
FAST_SWITCH_DECORATOR
int64_t save_and_restore(intptr_t arg, jb_t* jb1, void* sp) {
    SAVE_CONTEXT(jb1, cont);
    UNSEAL_STACK(sp, arg);
cont:
    return ret_val;
}

#define HANDLE_ONE(body, mode, func, ...) \
    ({ \
    intptr_t out; \
    if (mode == TAIL) { \
        handler_def_t* defs = STACK_ALLOC_ARRAY(handler_def_t, {mode, (void*)func}); \
        intptr_t* env = STACK_ALLOC_ARRAY(intptr_t, __VA_ARGS__); \
        handler_t *stub = STACK_ALLOC_STRUCT(handler_t, defs, env, NULL); \
        out = ((TailBodyFuncType)body)(stub); \
    } else { \
        if (mode == MULTISHOT || mode == SINGLESHOT) { \
            handler_def_t* defs = HEAP_ALLOC_ARRAY(handler_def_t, {mode, (void*)func}); \
            intptr_t* env = HEAP_ALLOC_ARRAY(intptr_t, __VA_ARGS__); \
            jb_t* ctx_jb = HEAP_ALLOC_STRUCT(jb_t); \
            exchanger_t* exc = HEAP_ALLOC_STRUCT(exchanger_t, ctx_jb, NULL); \
            handler_t *stub = HEAP_ALLOC_STRUCT(handler_t, defs, env, exc); \
            char* new_sp = get_stack(); \
            out = save_switch_and_run_body(ctx_jb, new_sp, (BodyFuncType)body, stub); \
            free_stack(new_sp); \
        } else { \
            handler_def_t* defs = STACK_ALLOC_ARRAY(handler_def_t, {mode, (void*)func}); \
            intptr_t* env = STACK_ALLOC_ARRAY(intptr_t, __VA_ARGS__); \
            jb_t* ctx_jb = STACK_ALLOC_STRUCT(jb_t); \
            exchanger_t* exc = STACK_ALLOC_STRUCT(exchanger_t, ctx_jb, NULL); \
            handler_t *stub = STACK_ALLOC_STRUCT(handler_t, defs, env, exc); \
            out = save_and_run_body(ctx_jb, (BodyFuncType)body, stub); \
        } \
    } \
    out; \
    })

#define HANDLE_TWO(body, mode1, func1, mode2, func2, ...) \
    ({ \
    intptr_t out; \
    if ((mode1 | mode2) == TAIL) { \
        handler_def_t* defs = STACK_ALLOC_ARRAY(handler_def_t, {mode1, (void*)func1}, {mode2, (void*)func2}); \
        intptr_t* env = STACK_ALLOC_ARRAY(intptr_t, __VA_ARGS__); \
        handler_t *stub = STACK_ALLOC_STRUCT(handler_t, defs, env, NULL); \
        out = body(stub); \
    } else { \
        if ((mode1 | mode2 & MULTISHOT) || (mode1 | mode2 & SINGLESHOT)) { \
            handler_def_t* defs = HEAP_ALLOC_ARRAY(handler_def_t, {mode1, (void*)func1}, {mode2, (void*)func2}); \
            intptr_t* env = HEAP_ALLOC_ARRAY(intptr_t, __VA_ARGS__); \
            jb_t* ctx_jb = HEAP_ALLOC_STRUCT(jb_t); \
            exchanger_t* exc = HEAP_ALLOC_STRUCT(exchanger_t, ctx_jb, NULL); \
            handler_t *stub = HEAP_ALLOC_STRUCT(handler_t, defs, env, exc); \
            char* new_sp = get_stack(); \
            out = save_switch_and_run_body(ctx_jb, new_sp, (BodyFuncType)body, stub); \
            free_stack(new_sp); \
        } else { \
            handler_def_t* defs = STACK_ALLOC_ARRAY(handler_def_t, {mode1, (void*)func1}, {mode2, (void*)func2}); \
            intptr_t* env = STACK_ALLOC_ARRAY(intptr_t, __VA_ARGS__); \
            jb_t* ctx_jb = STACK_ALLOC_STRUCT(jb_t); \
            exchanger_t* exc = STACK_ALLOC_STRUCT(exchanger_t, ctx_jb, NULL); \
            handler_t *stub = STACK_ALLOC_STRUCT(handler_t, defs, env, exc); \
            out = save_and_run_body(ctx_jb, (BodyFuncType)body, stub); \
        } \
    } \
    out; \
    })

#define RAISE(stub, index, arg) \
    ({ \
    intptr_t out; \
    switch (stub->defs[index].mode) { \
        case SINGLESHOT: \
        case MULTISHOT: {\
            out = save_switch_and_run_handler(stub->env, arg, stub->exchanger,\
                stub->exchanger->ctx_jb->reg_sp, &(stub->exchanger->rsp_sp), ((HandlerFuncType)stub->defs[index].func)); \
            break; \
        } \
        case TAIL: \
            out = ((TailHandlerFuncType)stub->defs[index].func)(stub->env, arg); \
            break; \
        case ABORT: \
            SWITCH_SP(stub->exchanger->ctx_jb->reg_sp); \
            ((HandlerFuncType)stub->defs[index].func)(stub->env, arg, stub->exchanger); \
            __builtin_unreachable(); \
    }; \
    out; \
    })

#define MAKE_RESUMPTION(exc) \
    HEAP_ALLOC_STRUCT(resumption_t, exc->rsp_sp, exc)

#define THROW(k, arg) \
    ({ \
    intptr_t out; \
    jb_t new_ctx_jb; \
    k->exc->ctx_jb = &new_ctx_jb; \
    char* new_sp = dup_stack((char*)k->rsp_sp); \
    out = save_and_restore(arg, k->exc->ctx_jb, new_sp); \
    free_stack(new_sp); \
    out; \
    })

#define FINAL_THROW(k, arg) \
    ({ \
    intptr_t out; \
    jb_t new_ctx_jb; \
    k->exc->ctx_jb = &new_ctx_jb; \
    out = save_and_restore(arg, k->exc->ctx_jb, k->rsp_sp); \
    out; \
    })

int64_t mathAbs(int64_t a) {
  return labs(a);
}

#define readInt() atoi(argv[1])
#define printInt(x) printf("%ld\n", x)