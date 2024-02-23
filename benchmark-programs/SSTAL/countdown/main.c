#include <stdint.h>
#include <stdio.h>
#include <defs.h>

static intptr_t ret_val;

int64_t get(intptr_t *env, int64_t _){
    intptr_t *s = (intptr_t*)env[0];
    return s[0];
}

int64_t set(intptr_t *env, int64_t n){
    intptr_t *s = (intptr_t*)env[0];
    s[0] = n;
    return 0;
}

// NOTE: declare functions with `static` sometimes helps the compiler to optimize the code
static int64_t countdown(handler_t* state_stub){
    int64_t i = RAISE(state_stub, 0, 0);
    if(i == 0){
        return i;
    } else {
        RAISE(state_stub, 1, i - 1);
        // NOTE: due to the presence of `setjmp` in the current function, the compiler refuses to do tail call optimization
        //     so we need to use the `musttail` attribute to force the tail call optimization
        __attribute__((musttail)) return countdown(state_stub); 
    }
}

// NOTE: declare functions with `static` sometimes helps the compiler to optimize the code
static int64_t run(int64_t n){
    // Heap-allocate a reference cell
    // NOTE: let's always heap-allocate the reference cells to align with the formalization.
    //     We can optimize this later if we want to.
    int64_t* s = (int64_t*)xmalloc(1 * sizeof(int64_t));
    *s = n;

    intptr_t env[1] = {(intptr_t)s};
    return HANDLE_TWO(countdown, TAIL, (void*)get, TAIL, (void*)set, env);
}

int main(int argc, char *argv[]){
    int64_t out = run(atoi(argv[1]));
    printf("%ld\n", out);
    return 0;
}