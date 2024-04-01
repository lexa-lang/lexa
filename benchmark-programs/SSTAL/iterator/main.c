#include <stdint.h>
#include <stdio.h>
#include <defs.h>

i64 emit(i64 env, i64 n) {
    i64 s = ((i64*)env)[1];
    *(i64*)s += n;
    return 0;
}

// TODO: enabling inline results in very aggressive optimizations.
// how to do this more principly?
__attribute__((always_inline))
i64 range(i64 emit_stub, i64 l, i64 u){
  return ({
    l > u ? 0 : ({
      RAISE(emit_stub, 0, (l));
      range(emit_stub, l + 1, u);
    });
  });
}

static i64 body(i64 emit_stub) {
    return ({
      range(emit_stub, 0, ((meta_t*)emit_stub)->env[0]);
      *(i64*)((meta_t*)emit_stub)->env[1];
    });
}

i64 run(i64 n){
    i64 s = (i64)xmalloc(1 * sizeof(i64));
    ((i64*)s)[0] = 0;
    
    return HANDLE(body, ({TAIL, (void*)emit}), (n, s));
}

int main(int argc, char *argv[]){
    printInt(run(readInt()));
    return 0;
}