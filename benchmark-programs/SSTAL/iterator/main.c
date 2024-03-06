#include <stdint.h>
#include <stdio.h>
#include <defs.h>

FAST_SWITCH_DECORATOR
intptr_t emit(intptr_t *env, intptr_t n) {
    intptr_t *a = (intptr_t*)env[0];
    *a += n;
    return 0;
}

intptr_t range(meta_t *emit_stub, intptr_t l, intptr_t u){
  return ({
    l > u ? 0 : ({
      RAISE(emit_stub, 0, l);
      range(emit_stub, l + 1, u);
    });
  });
}

FAST_SWITCH_DECORATOR
static intptr_t body(meta_t* emit_stub) {
    return ({
      range(emit_stub, 0, emit_stub->env[0]);
    });
}

intptr_t run(intptr_t n){
    intptr_t a = (intptr_t)xmalloc(1 * sizeof(intptr_t));
    ((intptr_t*)a)[0] = n;
    
    return HANDLE(body, ({TAIL, (void*)emit}), (a));
}

int main(int argc, char *argv[]){
    printInt(run(readInt()));
    return 0;
}