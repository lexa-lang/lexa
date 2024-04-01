#include <defs.h>

i64 get(i64 env){
    i64 s = ((i64*)env)[0];
    return ((i64*)s)[0];
}

i64 set(i64 env, i64 n){
    i64 s = ((i64*)env)[0];
    ((i64*)s)[0] = n;
    return 0;
}

// NOTE: declare functions with `static` sometimes helps the compiler to optimize the code
static i64 countdown(i64 state_stub){
    i64 i = RAISE(state_stub, 0, ());
    if(i == 0){
        return i;
    } else {
        RAISE(state_stub, 1, (i - 1));
        return countdown(state_stub); 
    }
}

static i64 body(i64 env, i64 state_stub) {
    return countdown(state_stub);
}

// NOTE: declare functions with `static` sometimes helps the compiler to optimize the code
static i64 run(i64 n){
    // Heap-allocate a reference cell
    // NOTE: let's always heap-allocate the reference cells to align with the formalization.
    //     We can optimize this later if we want to.
    i64 s = (i64)xmalloc(1 * sizeof(i64));
    ((i64*)s)[0] = n;

    return HANDLE(body, ({TAIL, (void*)get}, {TAIL, (void*)set}), (s));
}

int main(int argc, char *argv[]){
    printInt(run(readInt()));
    return 0;
}