#include <stdio.h>
#include <stdlib.h>
#include <stack_pool.h>

#define i64 intptr_t

typedef enum {
    TAIL = 1 << 0,
    ABORT = 1 << 1,
    SINGLESHOT = 1 << 2,
    MULTISHOT = 1 << 3,
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
  void* _sp_exchanger[1];
  void** sp_exchanger;
} meta_t;

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

__attribute__((noinline, naked))
FAST_SWITCH_DECORATOR
int64_t double_save_switch_and_run_handler(intptr_t* env, int64_t arg, resumption_t* k, void* func) {
    __asm__ (
        "movq 8(%%rdx), %%r8\n\t" // Get the exchanger from the resumption
        "movq 0(%%r8), %%rax\n\t" // Get the context stack from the exchanger
        "movq %%rsp, 0(%%r8)\n\t" // Save the current stack pointer to the exchanger. Later when switching back, just need to run a ret
        "movq %%rsp, 0(%%rdx)\n\t" // Save the current stack pointer to the resumption
        "movq %%rax, %%rsp\n\t" // Switch to the context stack
        "jmpq *%%rcx\n\t" // Call the handler, the first three arguments are already in the right registers
        :
    );
}

__attribute__((noinline, naked))
FAST_SWITCH_DECORATOR
int64_t save_switch_and_run_handler(intptr_t* env, int64_t arg, resumption_t* k, void* func) {
    __asm__ (
        "movq 0(%%rdx), %%rax\n\t" // Start to swap the context stack with the current stack
        "movq %%rsp, 0(%%rdx)\n\t" // Save the current stack pointer to exchanger. Later when switching back, just need to run a ret
        "movq %%rax, %%rsp\n\t" // Switch to the context stack
        "jmpq *%%rcx\n\t" // Call the handler, the first three arguments are already in the right registers
        :
    );
}

__attribute__((noinline))
int64_t save_switch_and_run_handler_wrapper(intptr_t* env, int64_t arg, resumption_t* k, void* func) {
    return save_switch_and_run_handler(env, arg, k, func);
}

// __attribute__((noinline, naked))
// FAST_SWITCH_DECORATOR
__attribute__((noinline)) // no inline to avoid code bloat
int64_t switch_free_and_run_handler(intptr_t* env, int64_t arg, void* target_sp, void* func) {
    void* curr_sp;
    __asm__ (
        "movq %%rsp, %0\n\t"
        : "=r"(curr_sp)
    );
    free_stack_on_abort(curr_sp, target_sp);
    __asm__ (
        "movq %2, %%rsp\n\t"
        "jmpq *%3\n\t"
        :: "D"(env), "S"(arg), "r"(target_sp), "r"(func)
    ); 
}

__attribute__((noinline, naked))
FAST_SWITCH_DECORATOR
int64_t save_switch_and_run_body(intptr_t* env, void* stub, void** exc, void* new_sp, void* body) {
    __asm__ (
        "movq %%rsp, 0(%%rdx)\n\t" // Save the current stack pointer to exchanger. Later when switching back, just need to run a ret
        "movq %%rcx, %%rsp\n\t" // Switch to the new stack new_sp
        "pushq %%rdx\n\t" // Save the exchanger in the stack
        "pushq %%rdx\n\t" // Ensure the stack is aligned
        "callq *%%r8\n\t"
        "movq %%rax, %%r12\n\t" // Save the return value into a callee-saved register
        "popq %%rbx\n\t" // Restore the exchanger into a callee-saved register
        "popq %%rbx\n\t" // Ensure the stack is aligned
        "movq %%rsp, %%rdi\n\t" // Move the current stack pointer to the first argument
        "callq free_stack\n\t" // Free the stack. NB HACK ATTENTTION!!!! This results in use-after-free in the next few instructions
        "movq 0(%%rbx), %%rsp\n\t" // Restore the parent stack pointer
        "movq %%r12, %%rax\n\t" // Move the return value to the return register
        "retq\n\t"
        :
    );
}

__attribute__((noinline, naked))
FAST_SWITCH_DECORATOR
int64_t save_and_run_body(intptr_t* env, void* stub, void** exc, void* body) {
    __asm__ (
        "movq %%rsp, 0(%%rdx)\n\t" // Save the current stack pointer to exchanger. Later when switching back, just need to run a ret
        "jmpq *%%rcx\n\t" // Call the body, the first argument is already in the right register
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

// Thie macro aggregate the modes of the handlers into one mode to guide the allocation of the meta,
// which happens in _HANDLE. Since the modes are compile-time constants, the compiler will optimize
// away the if-else chain.
#define HANDLE(body, m_defs, m_free_vars) \
({ \
    intptr_t out; \
    handler_def_t defs[] = {EXPAND m_defs}; \
    size_t n_defs = N_DEFS m_defs; \
    handler_mode_t mode = 0; \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warray-bounds\"") \
    if (defs[0].mode == TAIL || (n_defs > 1 && defs[1].mode == TAIL)) { \
        mode = TAIL; \
    } else if ((defs[0].mode & (SINGLESHOT | MULTISHOT)) || (n_defs > 1 && (defs[1].mode & (SINGLESHOT | MULTISHOT)))) { \
        if ((defs[0].mode & (MULTISHOT)) || (n_defs > 1 && (defs[1].mode & MULTISHOT))) { \
            mode |= MULTISHOT; \
        } else { \
            mode |= SINGLESHOT; \
        } \
    } else { \
        mode = ABORT; \
    } \
    _Pragma("clang diagnostic pop") \
    out = _HANDLE(mode, body, m_defs, m_free_vars); \
    out; \
})

#define _HANDLE(mode, body, m_defs, m_free_vars) \
    ({ \
    intptr_t out; \
    if (mode == TAIL) { \
        meta_t stub; \
        stub.defs = (handler_def_t[]){EXPAND m_defs}; \
        stub.env = (intptr_t[]) {EXPAND m_free_vars}; \
        out = body((intptr_t)stub.env, (intptr_t)&stub); \
    } else if (mode == ABORT) { \
        meta_t stub; \
        stub.defs = (handler_def_t[]){EXPAND m_defs}; \
        stub.env = (intptr_t[]) {EXPAND m_free_vars}; \
        stub.sp_exchanger = stub._sp_exchanger; \
        out = save_and_run_body(stub.env, (void*)&stub, stub.sp_exchanger, body); \
    } else { \
        handler_def_t _defs[] = {EXPAND m_defs}; \
        intptr_t _env[] = {EXPAND m_free_vars}; \
        char* new_sp = get_stack(); \
        new_sp -= sizeof(meta_t); \
        meta_t* stub = (meta_t*)new_sp; \
        stub->sp_exchanger = stub->_sp_exchanger; \
        new_sp -= sizeof(_defs); \
        memcpy(new_sp, _defs, sizeof(_defs)); \
        stub->defs = (handler_def_t*)new_sp; \
        new_sp -= sizeof(_env); \
        memcpy(new_sp, _env, sizeof(_env)); \
        stub->env = (intptr_t*)new_sp; \
        new_sp = (char*)((intptr_t)new_sp & ~0xF); \
        out = save_switch_and_run_body(stub->env, stub, stub->sp_exchanger, new_sp, body); \
    } \
    out; \
    })

#define RAISETAIL(_stub, index, m_args) \
    ({ \
    meta_t* stub = (meta_t*)_stub; \
    intptr_t out; \
    intptr_t nargs = NARGS m_args; \
    intptr_t args[] = {EXPAND m_args}; \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warray-bounds\"") \
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
    _Pragma("clang diagnostic pop") \
    out; \
    })

#define RAISEABORT(_stub, index, m_args) \
    ({ \
    meta_t* stub = (meta_t*)_stub; \
    intptr_t out; \
    intptr_t nargs = NARGS m_args; \
    intptr_t args[] = {EXPAND m_args}; \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warray-bounds\"") \
    if (nargs != 1) { printf("Number of args to raise unsupported\n"); exit(EXIT_FAILURE); } \
    switch_free_and_run_handler(stub->env, args[0], *stub->sp_exchanger, stub->defs[index].func); \
    _Pragma("clang diagnostic pop") \
    out; \
    })

#define RAISE(_stub, index, m_args) \
    ({ \
    meta_t* stub = (meta_t*)_stub; \
    intptr_t out; \
    intptr_t nargs = NARGS m_args; \
    intptr_t args[] = {EXPAND m_args}; \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warray-bounds\"") \
    handler_mode_t mode = stub->defs[index].mode & (TAIL | ABORT | SINGLESHOT | MULTISHOT); \
    switch (mode) { \
        case TAIL: { \
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
        } \
        case ABORT: { \
            if (nargs != 1) { printf("Number of args to raise unsupported\n"); exit(EXIT_FAILURE); } \
            switch_free_and_run_handler(stub->env, args[0], *stub->sp_exchanger, stub->defs[index].func); \
        } \
        case SINGLESHOT: { \
            if (nargs != 1) { printf("Number of args to raise unsupported\n"); exit(EXIT_FAILURE); } \
            resumption_t* k = (resumption_t*)(stub->sp_exchanger); \
            out = save_switch_and_run_handler(stub->env, args[0], k,\
                (stub->defs[index].func)); \
            break; \
        } \
        case MULTISHOT: { \
            if (nargs != 1) { printf("Number of args to raise unsupported\n"); exit(EXIT_FAILURE); } \
            resumption_t* k = (resumption_t*)xmalloc(sizeof(resumption_t)); \
            k->ctx_sp = stub->sp_exchanger; \
            out = double_save_switch_and_run_handler(stub->env, args[0], k,\
                (stub->defs[index].func)); \
            break; \
        } \
        default: { \
            exit(EXIT_FAILURE); \
        } \
    } \
    _Pragma("clang diagnostic pop") \
    out; \
    })

#define THROW(k, arg) \
    ({ \
    intptr_t out; \
    char* new_sp = dup_stack((char*)((resumption_t*)k)->rsp_sp); \
    out = save_and_restore(arg, ((resumption_t*)k)->ctx_sp, new_sp); \
    out; \
    })

#define FINAL_THROW(k, arg) \
    ({ \
    intptr_t out; \
    out = save_and_restore(arg, ((resumption_t*)k)->ctx_sp, ((resumption_t*)k)->rsp_sp); \
    out; \
    })

int64_t mathAbs(int64_t a) {
  return labs(a);
}

#define readInt() (argc == 2) ? atoi(argv[1]) : (printf("Usage: %s <int>\n", argv[0]), exit(EXIT_FAILURE), 0)
#define printInt(x) printf("%ld\n", x)