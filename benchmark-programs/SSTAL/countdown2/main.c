#include <stdint.h>
#include <stdio.h>
#include <defs.h>

intptr_t ret_val;

FAST_SWITCH_DECORATOR
intptr_t get(intptr_t *env, intptr_t _, void** exc) {
    resumption_t* k = MAKE_SINGLESHOT_RESUMPTION(exc);

    intptr_t *s = (intptr_t*)env[0];
    return FINAL_THROW(k, s[0]);
}

FAST_SWITCH_DECORATOR
intptr_t set(intptr_t *env, intptr_t n, void** exc) {
    resumption_t* k = MAKE_SINGLESHOT_RESUMPTION(exc);

    intptr_t *s = (intptr_t*)env[0];
    s[0] = n;
    return FINAL_THROW(k, 0);
}

// NOTE: declare functions with `static` sometimes helps the compiler to optimize the code
static intptr_t countdown(meta_t* state_stub){
    intptr_t i = RAISE(state_stub, 0, (0));
    if(i == 0){
        return i;
    } else {
        RAISE(state_stub, 1, (i - 1));
        return countdown(state_stub); 
    }
}

FAST_SWITCH_DECORATOR
static intptr_t body(meta_t* state_stub) {
    return countdown(state_stub);
}

// NOTE: declare functions with `static` sometimes helps the compiler to optimize the code
static intptr_t run(intptr_t n){
    // Heap-allocate a reference cell
    // NOTE: let's always heap-allocate the reference cells to align with the formalization.
    //     We can optimize this later if we want to.
    intptr_t s = (intptr_t)xmalloc(1 * sizeof(intptr_t));
    ((intptr_t*)s)[0] = n;

    return HANDLE(body, ({SINGLESHOT, (void*)get}, {SINGLESHOT, (void*)set}), (s));
}

int main(int argc, char *argv[]){
    init_stack_pool();
    printInt(run(readInt()));
    destroy_stack_pool();
    return 0;
}