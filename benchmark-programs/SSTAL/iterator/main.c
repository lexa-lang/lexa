#include <stdint.h>
#include <stdio.h>
#include <defs.h>

intptr_t emit(intptr_t *env, intptr_t n) {
    intptr_t *s = (intptr_t*)env[1];
    *s += n;
    return 0;
}

// TODO: enabling inline results in very aggressive optimizations.
// how to do this more principly?
__attribute__((always_inline))
intptr_t range(meta_t *emit_stub, intptr_t l, intptr_t u){
  return ({
    l > u ? 0 : ({
      RAISE(emit_stub, 0, (l));
      range(emit_stub, l + 1, u);
    });
  });
}

static intptr_t body(meta_t* emit_stub) {
    return ({
      range(emit_stub, 0, emit_stub->env[0]);
      *(intptr_t*)emit_stub->env[1];
    });
}

intptr_t run(intptr_t n){
    intptr_t s = (intptr_t)xmalloc(1 * sizeof(intptr_t));
    ((intptr_t*)s)[0] = 0;
    
    return HANDLE(body, ({TAIL, (void*)emit}), (n, s));
}

int main(int argc, char *argv[]){
    printInt(run(readInt()));
    return 0;
}