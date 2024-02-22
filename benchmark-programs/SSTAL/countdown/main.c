#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
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

static intptr_t ret_val;

#define xmalloc(size) ({                \
    void *_ptr = malloc(size);          \
    if (_ptr == NULL) {                 \
        exit(EXIT_FAILURE);             \
    }                                   \
    _ptr;                               \
})

int64_t get(intptr_t env[1], int64_t _){
    return *(int64_t*)env[0];
}

int64_t set(intptr_t env[1], int64_t n){
    *(int64_t*)env[0] = n;
    return n;
}

int countdown(handler_t* hdl_stub){
    // Invoke get
    int64_t arg = 0;
    int64_t out;
    const handler_def_t get_def = hdl_stub->defs[0];
    const behaviour_t behaviour = get_def.behavior;
    const void* func = get_def.func;
    const intptr_t* env = hdl_stub->env;
    exchanger_t* exc = hdl_stub->exchanger;
    switch (behaviour) {
        case GENERAL:
            exc->rsp_jb = (mp_jmpbuf_t*)xmalloc(sizeof(mp_jmpbuf_t));
            if (mp_setjmp(exc->rsp_jb) == 0) {
                __asm__ (
                    "movq %0, %%rsp\n\t"
                    :: "r"(exc->ctx_jb->reg_sp)
                );
                ((void(*)(const intptr_t* const, exchanger_t*, int64_t))func)(env, exc, arg);
                __builtin_unreachable();
            } else {
                out = (int64_t)ret_val;
            }
            break;
        case TAIL:
            out = ((int64_t(*)(const intptr_t* const, int64_t))func)(env, arg);
            break;
        case ABORT:
            __asm__ (
                "movq %0, %%rsp\n\t"
                :: "r"(exc->ctx_jb->reg_sp)
            );
            ((void(*)(const intptr_t* const, exchanger_t*, int64_t))func)(env, exc, arg);
            __builtin_unreachable();
    }
    if(out == 0){
        return out;
    } else {
        // Invoke set
        int64_t arg = out - 1;
        int64_t out;
        handler_def_t set_def = (handler_def_t)hdl_stub->defs[1];
        switch (set_def.behavior) {
            case GENERAL:
                // TODO
            case TAIL:
                out = ((int64_t(*)(const intptr_t* const, int64_t))set_def.func)(hdl_stub->env, arg);
                break;
            case ABORT:
                __asm__ (
                    "movq %0, %%rsp\n\t"
                    :: "r"(hdl_stub->exchanger->ctx_jb->reg_sp)
                );
                ((void(*)(const intptr_t* const, exchanger_t*, int64_t))set_def.func)(hdl_stub->env, hdl_stub->exchanger, arg);
                __builtin_unreachable();
        };
        // Recurse
        return countdown(hdl_stub);
    }
}

int64_t run(int64_t n){
    // Heap-allocate a reference cell
    int64_t* a = (int64_t*)xmalloc(1 * sizeof(int64_t));
    *a = n;

    // stack allocate the handles' definitions
    handler_def_t hdl_defs[2] = {{TAIL, (void*)get}, {TAIL, (void*)set}};
    // stack allocate the handler and handle body's environment
    intptr_t hdl_env[1] = {(intptr_t)a};
    // stack allocate the handler struct
    handler_t *hdl_stub = &(handler_t){.defs = hdl_defs, .env = hdl_env, .exchanger = NULL};
    // run the handle body
    int64_t out = countdown(hdl_stub);
    return out;
}

int main(int argc, char *argv[]){
    int out = run(atoi(argv[1]));
    printf("%d\n", out);
    return 0;
}