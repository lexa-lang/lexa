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
  void *ctx_sp;
  void *rsp_sp;
} exchanger_t;

typedef struct {
    void* rsp_sp;
    void** ctx_sp;
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
        "movq %%rsp, 0(%%r8)\n\t" // Save the current stack pointer to rsp_sp. Later when switching back, just need to run a ret
        "movq %%rcx, %%rsp\n\t" // Switch to the context stack ctx_sp
        "jmpq *%%r9\n\t" // Call the handler, the first three arguments are already in the right registers
        :
    );
}

__attribute__((noinline, naked))
FAST_SWITCH_DECORATOR
int64_t save_switch_and_run_body(handler_t* stub, void** ctx_sp, void* new_sp, BodyFuncType body) {
    __asm__ (
        "movq %%rsp, 0(%%rsi)\n\t" // Save the current stack pointer to ctx_sp. Later when switching back, just need to run a ret
        "movq %%rdx, %%rsp\n\t" // Switch to the new stack new_sp
        "movq %%rsi, %%rbx\n\t" // Save the pointer to the parent stack pointer in a callee-saved register
        "callq *%%rcx\n\t"
        "movq 0(%%rbx), %%rsp\n\t" // Restore the parent stack pointer
        "retq\n\t"
        :
    );
}

__attribute__((noinline, naked))
FAST_SWITCH_DECORATOR
int64_t save_and_run_body(handler_t* stub, void** ctx_sp, BodyFuncType body) {
    __asm__ (
        "movq %%rsp, 0(%%rsi)\n\t" // Save the current stack pointer to ctx_sp. Later when switching back, just need to run a ret
        "jmpq *%%rdx\n\t" // Call the body, the first argument is already in the right register
        :
    );
}

__attribute__((noinline, naked))
FAST_SWITCH_DECORATOR
int64_t save_and_restore(intptr_t arg, void** ctx_sp, void* rsp_sp) {
    __asm__ (
        "movq %%rsp, 0(%%rsi)\n\t" // Save the current stack pointer to rsp_sp. Later when switching back, just need to run a ret
        "movq %%rdx, %%rsp\n\t" // Switch to the new stack rsp_sp
        "movq %%rdi, %%rax\n\t" // Move the argument(return value) to the return register
        "retq\n\t"
        :
    );
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
            exchanger_t* exc = HEAP_ALLOC_STRUCT(exchanger_t, NULL, NULL); \
            handler_t *stub = HEAP_ALLOC_STRUCT(handler_t, defs, env, exc); \
            char* new_sp = get_stack(); \
            out = save_switch_and_run_body(stub, &(exc->ctx_sp), new_sp, (BodyFuncType)body); \
            free_stack(new_sp); \
        } else { \
            handler_def_t* defs = STACK_ALLOC_ARRAY(handler_def_t, {mode, (void*)func}); \
            intptr_t* env = STACK_ALLOC_ARRAY(intptr_t, __VA_ARGS__); \
            exchanger_t* exc = STACK_ALLOC_STRUCT(exchanger_t, NULL, NULL); \
            handler_t *stub = STACK_ALLOC_STRUCT(handler_t, defs, env, exc); \
            out = save_and_run_body(stub, &(exc->ctx_sp), (BodyFuncType)body); \
        } \
    }\
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
            exchanger_t* exc = HEAP_ALLOC_STRUCT(exchanger_t, NULL, NULL); \
            handler_t *stub = HEAP_ALLOC_STRUCT(handler_t, defs, env, exc); \
            char* new_sp = get_stack(); \
            out = save_switch_and_run_body(stub, &(exc->ctx_sp), new_sp, (BodyFuncType)body); \
            free_stack(new_sp); \
        } else { \
            handler_def_t* defs = STACK_ALLOC_ARRAY(handler_def_t, {mode1, (void*)func1}, {mode2, (void*)func2}); \
            intptr_t* env = STACK_ALLOC_ARRAY(intptr_t, __VA_ARGS__); \
            exchanger_t* exc = STACK_ALLOC_STRUCT(exchanger_t, NULL, NULL); \
            handler_t *stub = STACK_ALLOC_STRUCT(handler_t, defs, env, exc); \
            out = save_and_run_body(stub, &(exc->ctx_sp), (BodyFuncType)body); \
        } \
    }\
    out; \
    })

#define RAISE(stub, index, arg) \
    ({ \
    intptr_t out; \
    switch (stub->defs[index].mode) { \
        case SINGLESHOT: \
        case MULTISHOT: {\
            out = save_switch_and_run_handler(stub->env, arg, stub->exchanger,\
                stub->exchanger->ctx_sp, &(stub->exchanger->rsp_sp), ((HandlerFuncType)stub->defs[index].func)); \
            break; \
        } \
        case TAIL: \
            out = ((TailHandlerFuncType)stub->defs[index].func)(stub->env, arg); \
            break; \
        case ABORT: \
            __asm__ ( \
                "movq %3, %%rsp\n\t" \
                "jmpq *%4\n\t" \
                :: "D"(stub->env), "S"(arg), "d"(stub->exchanger), "r"(stub->exchanger->ctx_sp), "r"((HandlerFuncType)stub->defs[index].func) \
            ); \
            __builtin_unreachable(); \
    }; \
    out; \
    })

#define MAKE_RESUMPTION(exc) \
    HEAP_ALLOC_STRUCT(resumption_t, exc->rsp_sp, &exc->ctx_sp)

#define THROW(k, arg) \
    ({ \
    intptr_t out; \
    char* new_sp = dup_stack((char*)k->rsp_sp); \
    out = save_and_restore(arg, k->ctx_sp, new_sp); \
    free_stack(new_sp); \
    out; \
    })

#define FINAL_THROW(k, arg) \
    ({ \
    intptr_t out; \
    out = save_and_restore(arg, k->ctx_sp, k->rsp_sp); \
    out; \
    })

int64_t mathAbs(int64_t a) {
  return labs(a);
}

#define readInt() atoi(argv[1])
#define printInt(x) printf("%ld\n", x)