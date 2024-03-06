#include <stdint.h>
#include <stdio.h>
#include <defs.h>

intptr_t emit(intptr_t *env, intptr_t n) {
    intptr_t *s = (intptr_t*)env[1];
    *s += n;
    return 0;
}

intptr_t echo(intptr_t *env, intptr_t n) {
    return n;
}

intptr_t range(meta_t*, meta_t*, intptr_t, intptr_t);

static intptr_t emitter(meta_t* emit_stub, intptr_t i) {
  if (i > 0) {
    RAISE(emit_stub, 0, i);
    emitter(emit_stub, i - 1);
  }
}

static intptr_t body3(meta_t* echo_stub) {
  return range(echo_stub, (meta_t*)echo_stub->env[2], echo_stub->env[0] + 1, echo_stub->env[1]);
}

intptr_t range(meta_t *echo_stub, meta_t *emit_stub, intptr_t l, intptr_t u) {
  return ({
    l > u ? emitter(emit_stub, 100000) : ({
      HANDLE(body3, ({TAIL, (void*)echo}), (l, u, (intptr_t)emit_stub));
    });
  });
}

static intptr_t body2(meta_t* echo_stub) {
    return ({
      range(echo_stub, (meta_t*)echo_stub->env[2], 0, echo_stub->env[0]);
      *(intptr_t*)echo_stub->env[1];
    });
}

static intptr_t body(meta_t* emit_stub) {
    return ({
      HANDLE(body2, ({TAIL, (void*)echo}), (emit_stub->env[0], emit_stub->env[1], (intptr_t)emit_stub));
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