#include <stdio.h>
#include <stdlib.h>
#include <stack_pool.h>

#define i64 intptr_t

typedef enum {
    ABORT = 0,
    SINGLESHOT,
    MULTISHOT,
    TAIL,
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
  i64* env;
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

#define ARG_N(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, N, ...) N
#define NARGS(...) ARG_N(_, ## __VA_ARGS__, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0)

FAST_SWITCH_DECORATOR
i64 double_save_switch_and_run_handler(meta_t* stub, i64 index, i64 arg) {
    resumption_t* k = (resumption_t*)xmalloc(sizeof(resumption_t));
    k->ctx_sp = stub->sp_exchanger;
    __asm__ (
        "popq %%rax\n\t" // Pop the dummy slot that is used to align the stack. It is inserted by the compiler, and is needed because of the malloc call. We pop it off because we want to expose the return address
        "movq 8(%%rdx), %%r8\n\t" // Get the exchanger from the resumption
        "movq 0(%%r8), %%rax\n\t" // Get the context stack from the exchanger
        "movq %%rsp, 0(%%r8)\n\t" // Save the current stack pointer to the exchanger. Later when switching back, just need to run a ret
        "movq %%rsp, 0(%%rdx)\n\t" // Save the current stack pointer to the resumption
        "movq %%rax, %%rsp\n\t" // Switch to the context stack
        "jmpq *%%rcx\n\t" // Call the handler, the first three arguments are already in the right registers
        :: "D"(stub->env), "S"(arg), "d"(k), "c"(stub->defs[index].func)
    );
}

FAST_SWITCH_DECORATOR
i64 save_switch_and_run_handler(meta_t* stub, i64 index, i64 arg) {
    __asm__ (
        "movq 0(%%rdx), %%rax\n\t" // Start to swap the context stack with the current stack
        "movq %%rsp, 0(%%rdx)\n\t" // Save the current stack pointer to exchanger. Later when switching back, just need to run a ret
        "movq %%rax, %%rsp\n\t" // Switch to the context stack
        "jmpq *%%rcx\n\t" // Call the handler, the first three arguments are already in the right registers
        :: "D"(stub->env), "S"(arg), "d"(stub->sp_exchanger), "c"(stub->defs[index].func)
    );
}

i64 switch_free_and_run_handler(meta_t* stub, i64 index, i64 arg) {
    void* target_sp = *stub->sp_exchanger;
    void* curr_sp;
    __asm__ (
        "movq %%rsp, %0\n\t"
        : "=r"(curr_sp)
    );
    free_stack_on_abort(curr_sp, target_sp);
    __asm__ (
        "movq %2, %%rsp\n\t"
        "jmpq *%3\n\t"
        :: "D"(stub->env), "S"(arg), "r"(target_sp), "r"(stub->defs[index].func)
    ); 
}

i64 run_1_arg_handler_in_place(meta_t* stub, i64 index, i64 arg) {
    return ((i64(*)(i64*, i64))stub->defs[index].func)(stub->env, arg);
}

__attribute__((noinline, naked))
FAST_SWITCH_DECORATOR
i64 save_switch_and_run_body(i64* env, void* stub, void** exc, void* new_sp, void* body) {
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
i64 save_and_run_body(i64* env, void* stub, void** exc, void* body) {
    __asm__ (
        "movq %%rsp, 0(%%rdx)\n\t" // Save the current stack pointer to exchanger. Later when switching back, just need to run a ret
        "jmpq *%%rcx\n\t" // Call the body, the first argument is already in the right register
        :
    );
}

__attribute__((noinline, naked))
FAST_SWITCH_DECORATOR
i64 save_and_restore(i64 arg, void** exc, void* rsp_sp) {
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
    i64 out; \
    handler_def_t defs[] = {EXPAND m_defs}; \
    size_t n_defs = N_DEFS m_defs; \
    handler_mode_t mode = 0; \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warray-bounds\"") \
    if (defs[0].mode == TAIL || (n_defs > 1 && defs[1].mode == TAIL)) { \
        mode = TAIL; \
    } else if (((defs[0].mode == SINGLESHOT) || (defs[0].mode == MULTISHOT)) || (n_defs > 1 && ((defs[1].mode == SINGLESHOT) || (defs[1].mode == MULTISHOT)))) { \
        if (((defs[0].mode == MULTISHOT)) || (n_defs > 1 && (defs[1].mode == MULTISHOT))) { \
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
    i64 out; \
    if (mode == TAIL) { \
        meta_t stub; \
        stub.defs = (handler_def_t[]){EXPAND m_defs}; \
        stub.env = (i64[]) {EXPAND m_free_vars}; \
        out = body((i64)stub.env, (i64)&stub); \
    } else if (mode == ABORT) { \
        meta_t stub; \
        stub.defs = (handler_def_t[]){EXPAND m_defs}; \
        stub.env = (i64[]) {EXPAND m_free_vars}; \
        stub.sp_exchanger = stub._sp_exchanger; \
        out = save_and_run_body(stub.env, (void*)&stub, stub.sp_exchanger, body); \
    } else { \
        handler_def_t _defs[] = {EXPAND m_defs}; \
        i64 _env[] = {EXPAND m_free_vars}; \
        char* new_sp = get_stack(); \
        new_sp -= sizeof(meta_t); \
        meta_t* stub = (meta_t*)new_sp; \
        stub->sp_exchanger = stub->_sp_exchanger; \
        new_sp -= sizeof(_defs); \
        memcpy(new_sp, _defs, sizeof(_defs)); \
        stub->defs = (handler_def_t*)new_sp; \
        new_sp -= sizeof(_env); \
        memcpy(new_sp, _env, sizeof(_env)); \
        stub->env = (i64*)new_sp; \
        new_sp = (char*)((i64)new_sp & ~0xF); \
        out = save_switch_and_run_body(stub->env, stub, stub->sp_exchanger, new_sp, body); \
    } \
    out; \
    })

#define RAISET(_stub, index, m_args) \
    ({ \
    meta_t* stub = (meta_t*)_stub; \
    i64 out; \
    i64 nargs = NARGS m_args; \
    i64 args[] = {EXPAND m_args}; \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warray-bounds\"") \
    if (nargs == 0) { \
        out = ((i64(*)(i64*))stub->defs[index].func)(stub->env); \
    } else if (nargs == 1) { \
        out = ((i64(*)(i64*, i64))stub->defs[index].func)(stub->env, args[0]); \
    } else if (nargs == 2) { \
        out = ((i64(*)(i64*, i64, i64))stub->defs[index].func)(stub->env, args[0], args[1]); \
    } else if (nargs == 3) { \
        out = ((i64(*)(i64*, i64, i64, i64))stub->defs[index].func)(stub->env, args[0], args[1], args[2]); \
    } else { \
        exit(EXIT_FAILURE); \
    } \
    _Pragma("clang diagnostic pop") \
    out; \
    })

#define RAISEA(_stub, index, m_args) \
    ({ \
    meta_t* stub = (meta_t*)_stub; \
    i64 out; \
    i64 nargs = NARGS m_args; \
    i64 args[] = {EXPAND m_args}; \
    if (nargs != 1) { printf("Number of args to raise unsupported\n"); exit(EXIT_FAILURE); } \
    switch_free_and_run_handler(stub, index, args[0]); \
    out; \
    })

#define RAISES(_stub, index, m_args) \
    ({ \
    meta_t* stub = (meta_t*)_stub; \
    i64 out; \
    i64 nargs = NARGS m_args; \
    i64 args[] = {EXPAND m_args}; \
    if (nargs != 1) { printf("Number of args to raise unsupported\n"); exit(EXIT_FAILURE); } \
    out = save_switch_and_run_handler(stub, index, args[0]); \
    out; \
    })

#define RAISEM(_stub, index, m_args) \
    ({ \
    meta_t* stub = (meta_t*)_stub; \
    i64 out; \
    i64 nargs = NARGS m_args; \
    i64 args[] = {EXPAND m_args}; \
    if (nargs != 1) { printf("Number of args to raise unsupported\n"); exit(EXIT_FAILURE); } \
    out = double_save_switch_and_run_handler(stub, index, args[0]); \
    out; \
    })

i64 (FAST_SWITCH_DECORATOR* stack_switching_functions[3])(meta_t* stub, i64 index, i64 arg) = {
    (long (FAST_SWITCH_DECORATOR*)(meta_t *, long, long) )switch_free_and_run_handler,
    save_switch_and_run_handler,
    double_save_switch_and_run_handler
};

#define RAISE(_stub, index, m_args) \
    ({ \
    meta_t* stub = (meta_t*)_stub; \
    i64 out; \
    i64 nargs = NARGS m_args; \
    i64 args[] = {EXPAND m_args}; \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warray-bounds\"") \
    if (stub->defs[index].mode == TAIL) { \
        if (nargs == 0) { \
            out = ((i64(*)(i64*))stub->defs[index].func)(stub->env); \
        } else if (nargs == 1) { \
            out = ((i64(*)(i64*, i64))stub->defs[index].func)(stub->env, args[0]); \
        } else if (nargs == 2) { \
            out = ((i64(*)(i64*, i64, i64))stub->defs[index].func)(stub->env, args[0], args[1]); \
        } else if (nargs == 3) { \
            out = ((i64(*)(i64*, i64, i64, i64))stub->defs[index].func)(stub->env, args[0], args[1], args[2]); \
        } else { \
            exit(EXIT_FAILURE); \
        } \
    } else { \
        if (nargs != 1) { printf("Number of args to raise unsupported\n"); exit(EXIT_FAILURE); } \
        out = stack_switching_functions[stub->defs[index].mode](stub, index, args[0]); \
    } \
    _Pragma("clang diagnostic pop") \
    out; \
    })

#define THROW(k, arg) \
    ({ \
    i64 out; \
    char* new_sp = dup_stack((char*)((resumption_t*)k)->rsp_sp); \
    out = save_and_restore(arg, ((resumption_t*)k)->ctx_sp, new_sp); \
    out; \
    })

#define FINAL_THROW(k, arg) \
    ({ \
    i64 out; \
    out = save_and_restore(arg, ((resumption_t*)k)->ctx_sp, ((resumption_t*)k)->rsp_sp); \
    out; \
    })

i64 mathAbs(i64 a) {
  return labs(a);
}

#define readInt() (argc == 2) ? atoi(argv[1]) : (printf("Usage: %s <int>\n", argv[0]), exit(EXIT_FAILURE), 0)
#define printInt(x) printf("%ld\n", x)