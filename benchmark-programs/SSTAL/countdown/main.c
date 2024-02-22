#include <stdint.h>
#include <stdio.h>
#include <defs.h>

static intptr_t ret_val;

int64_t get(intptr_t *env, int64_t _){
    return *(int64_t*)env[0];
}

int64_t set(intptr_t *env, int64_t n){
    *(int64_t*)env[0] = n;
    return 0;
}

// NOTE: declare functions with `static` sometimes helps the compiler to optimize the code
static int64_t countdown(handler_t* hdl_stub){
    int64_t out;
    RAISE(out, hdl_stub, 0, 0);
    int64_t i = out;
    if(i == 0){
        return i;
    } else {
        int64_t out;
        RAISE(out, hdl_stub, 1, i - 1);
        // NOTE: due to the presence of `setjmp` in the current function, the compiler refuses to do tail call optimization
        //     so we need to use the `musttail` attribute to force the tail call optimization
        __attribute__((musttail)) return countdown(hdl_stub); 
    }
}

// NOTE: declare functions with `static` sometimes helps the compiler to optimize the code
static int64_t run(int64_t n){
    // Heap-allocate a reference cell
    // NOTE: let's always heap-allocate the reference cells to align with the formalization.
    //     We can optimize this later if we want to.
    int64_t* s = (int64_t*)xmalloc(1 * sizeof(int64_t));
    *s = n;

    // NOTE: let's always allocate handler stubs on the stack. Only in very rare cases we need to allocate it on the heap,
    //     and let's not worry about that for now.
    // stack allocate the handles' definitions
    handler_def_t hdl_defs[2] = {{TAIL, (void*)get}, {TAIL, (void*)set}};
    // stack allocate the handler and handle body's environment
    intptr_t hdl_env[1] = {(intptr_t)s};
    // stack allocate the handler struct
    // NOTE: the `exchanger` field is set to `NULL` because all handlers we have are tail-recursive
    handler_t *hdl_stub = &(handler_t){.defs = hdl_defs, .env = hdl_env, .exchanger = NULL};
    // run the handle body
    int64_t out = countdown(hdl_stub);
    return out;
}

int main(int argc, char *argv[]){
    int64_t out = run(atoi(argv[1]));
    printf("%ld\n", out);
    return 0;
}