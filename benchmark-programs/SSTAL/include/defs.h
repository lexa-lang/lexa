#include <stdlib.h>
#include <stack_pool.h>

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
  // HACK: sp_exchanger stores the address of _sp_exchanger. We use this indirection
  // to convince the compiler that this struct is immutable, so optimization such as
  // argpromotion can proceed.
  handler_def_t* defs;
  intptr_t* env;
  void** sp_exchanger;
  void* _sp_exchanger[1];
} meta_t;

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
    void* rsp_sp;
    void** ctx_sp;
} resumption_t;

#define xmalloc(size) ({                \
    void *_ptr = malloc(size);          \
    if (_ptr == NULL) {                 \
        exit(EXIT_FAILURE);             \
    }                                   \
    _ptr;                               \
})

extern intptr_t ret_val;

#define ARG_N(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, N, ...) N
#define NARGS(...) ARG_N(_, ## __VA_ARGS__, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0)

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
int64_t save_switch_and_run_handler(intptr_t* env, int64_t arg, void** exc, void* func) {
    __asm__ (
        "movq 0(%%rdx), %%rax\n\t" // Start to swap the context stack with the current stack
        "movq %%rsp, 0(%%rdx)\n\t" // Save the current stack pointer to exchanger. Later when switching back, just need to run a ret
        "movq %%rax, %%rsp\n\t" // Switch to the context stack
        "jmpq *%%rcx\n\t" // Call the handler, the first three arguments are already in the right registers
        :
    );
}

__attribute__((noinline, naked))
FAST_SWITCH_DECORATOR
int64_t save_switch_and_run_body(void* stub, void** exc, void* new_sp, void* body) {
    __asm__ (
        "movq %%rsp, 0(%%rsi)\n\t" // Save the current stack pointer to exchanger. Later when switching back, just need to run a ret
        "movq %%rdx, %%rsp\n\t" // Switch to the new stack new_sp
        "pushq %%rsi\n\t" // Save the exchanger in the stack
        "pushq %%rsi\n\t" // Ensure the stack is aligned
        "callq *%%rcx\n\t"
        "movq %%rax, %%r12\n\t" // Save the return value into a callee-saved register
        "popq %%rbx\n\t" // Restore the exchanger into a callee-saved register
        "popq %%rbx\n\t" // Ensure the stack is aligned
        "movq %%rsp, %%rdi\n\t" // Move the current stack pointer to the first argument
        "callq free_stack\n\t" // Free the stack
        "movq 0(%%rbx), %%rsp\n\t" // Restore the parent stack pointer
        "movq %%r12, %%rax\n\t" // Move the return value to the return register
        "retq\n\t"
        :
    );
}

__attribute__((noinline, naked))
FAST_SWITCH_DECORATOR
int64_t save_and_run_body(void* stub, void** exc, void* body) {
    __asm__ (
        "movq %%rsp, 0(%%rsi)\n\t" // Save the current stack pointer to exchanger. Later when switching back, just need to run a ret
        "jmpq *%%rdx\n\t" // Call the body, the first argument is already in the right register
        :
    );
}

__attribute__((noinline, naked))
FAST_SWITCH_DECORATOR
int64_t save_and_restore(intptr_t arg, void** exc, void* rsp_sp) {
    __asm__ (
        "movq %%rsp, 0(%%rsi)\n\t" // Save the current stack pointer to exchanger. Later when switching back, just need to run a ret
        "movq %%rdx, %%rsp\n\t" // Switch to the new stack rsp_sp
        "movq %%rdi, %%rax\n\t" // Move the argument(return value) to the return register
        "retq\n\t"
        :
    );
}

#define FIRST(x, ...) x
#define SECOND(x, y, ...) y
#define THIRD(x, y, z, ...) z
#define GET_FUNC(func, mode) func
#define GET_MODE(func, mode) mode
#define EXPAND(...) __VA_ARGS__
#define CONCAT(a, b) a ## b
#define CONCAT_EXPAND(a, b) CONCAT(a, b)
#define CONCAT5(a, b, c, d, e) a ## b ## c ## d ## e
#define CONCAT5_EXPAND(a, b, c, d, e) CONCAT5(a, b, c, d, e)

#define N_DEFS(...) ARG_N(_, ## __VA_ARGS__, 5, OOPS, 4, OOPS, 3, OOPS, 2, OOPS, 1, OOPS, 0)

#define HANDLE(body, m_defs, m_free_vars) \
({ \
    intptr_t out; \
    handler_def_t defs[] = {EXPAND m_defs}; \
    size_t n_defs = N_DEFS m_defs; \
    handler_mode_t mode; \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warray-bounds\"") \
    if (defs[0].mode == TAIL && (n_defs <= 1 || defs[1].mode == TAIL)) { \
        mode = TAIL; \
    } else if ((defs[0].mode & (SINGLESHOT | MULTISHOT)) && (n_defs <= 1 || (defs[1].mode & (SINGLESHOT | MULTISHOT)))) { \
        mode = MULTISHOT; \
    } else { \
        mode = ABORT; \
    } \
    _Pragma("clang diagnostic pop") \
    out = _HANDLE(mode, body, m_defs, m_free_vars); \
    out; \
})

// TODO: improvement. For general handlers, if k doesn't escape, which is the common case,
// the meta can be stack-allocated on the parent stack. If k escape, it can be stack-allocated
// on the new stack. The later is slightly less efficient because it requires an extra copy.
#define _HANDLE(mode, body, m_defs, m_free_vars) \
    ({ \
    intptr_t out; \
    if (mode == TAIL) { \
        meta_t stub; \
        stub.defs = (handler_def_t[]){EXPAND m_defs}; \
        stub.env = (intptr_t[]) {EXPAND m_free_vars}; \
        out = body(&stub); \
    } else { \
        if (mode == MULTISHOT) { \
            meta_t* stub = (meta_t*)xmalloc(sizeof(meta_t)); \
            handler_def_t _defs[] = {EXPAND m_defs}; \
            stub->defs = (handler_def_t*)xmalloc(sizeof(handler_def_t) * (N_DEFS m_defs)); \
            memcpy(stub->defs, _defs, sizeof(handler_def_t) * (N_DEFS m_defs)); \
            intptr_t _env[] = {EXPAND m_free_vars}; \
            stub->env = (intptr_t*)xmalloc(sizeof(intptr_t) * (NARGS m_free_vars)); \
            memcpy(stub->env, _env, sizeof(intptr_t) * (NARGS m_free_vars)); \
            stub->sp_exchanger = stub->_sp_exchanger; \
            char* new_sp = get_stack(); \
            out = save_switch_and_run_body(stub, stub->sp_exchanger, new_sp, body); \
        } else { \
            meta_t stub; \
            stub.defs = (handler_def_t[]){EXPAND m_defs}; \
            stub.env = (intptr_t[]) {EXPAND m_free_vars}; \
            stub.sp_exchanger = stub._sp_exchanger; \
            out = save_and_run_body(&stub, stub.sp_exchanger, body); \
        } \
    } \
    out; \
    })

#define RAISE(stub, index, m_args) \
    ({ \
    intptr_t out; \
    intptr_t nargs = NARGS m_args; \
    intptr_t args[] = {EXPAND m_args}; \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warray-bounds\"") \
    switch (stub->defs[index].mode) { \
        case SINGLESHOT: \
        case MULTISHOT: {\
            if (nargs != 1) { exit(EXIT_FAILURE); } \
            out = save_switch_and_run_handler(stub->env, args[0], stub->sp_exchanger,\
                (stub->defs[index].func)); \
            break; \
        } \
        case TAIL: \
            if (nargs == 0) { \
                out = ((intptr_t(*)(intptr_t*))stub->defs[index].func)(stub->env); \
            } else if (nargs == 1) { \
                out = ((intptr_t(*)(intptr_t*, intptr_t))stub->defs[index].func)(stub->env, args[0]); \
            } else if (nargs == 2) { \
                out = ((intptr_t(*)(intptr_t*, intptr_t, intptr_t))stub->defs[index].func)(stub->env, args[0], args[1]); \
            } else if (nargs == 3) { \
                out = ((intptr_t(*)(intptr_t*, intptr_t, intptr_t, intptr_t))stub->defs[index].func)(stub->env, args[0], args[1], args[2]); \
            } else { \
                exit(EXIT_FAILURE); \
            } \
            break; \
        case ABORT: \
            if (nargs != 1) { exit(EXIT_FAILURE); } \
            __asm__ ( \
                "movq %2, %%rsp\n\t" \
                "jmpq *%3\n\t" \
                :: "D"(stub->env), "S"(args[0]), "r"(*stub->sp_exchanger), "r"(stub->defs[index].func) \
            ); \
            __builtin_unreachable(); \
    }; \
    _Pragma("clang diagnostic pop") \
    out; \
    })

#define MAKE_RESUMPTION(exc) \
    HEAP_ALLOC_STRUCT(resumption_t, *exc, exc)

#define THROW(k, arg) \
    ({ \
    intptr_t out; \
    char* new_sp = dup_stack((char*)k->rsp_sp); \
    out = save_and_restore(arg, k->ctx_sp, new_sp); \
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