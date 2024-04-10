  $ sstal ../lexi/countdown/main.ir -o main.c
  $ cat main.c
  #include <stdint.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include <stdbool.h>
  #include <string.h>
  #include <defs.h>
  #include <datastructure.h>
  
  static i64 run(i64);
  static i64 body(i64,i64);
   i64 set(i64*,i64);
   i64 get(i64*,i64);
  static i64 countdown(i64);
  
  static i64 countdown(i64 state_stub) {
  return(({i64 i = (i64)(RAISE(state_stub, 0, (0)));
  ({i64 cond = (i64)(i == 0);
  (cond) ? (i) : (({i64 arg = (i64)(i - 1);
  ({i64 _ = (i64)(RAISE(state_stub, 1, (arg)));
  ((i64(*)(i64))countdown)(state_stub);});}));});}));
  }
  
   i64 get(i64* env,i64 _) {
  return(({i64 s = (i64)(((i64*)env)[0]);
  ((i64*)s)[0];}));
  }
  
   i64 set(i64* env,i64 i) {
  return(({i64 s = (i64)(((i64*)env)[0]);
  ({i64 _ = (i64)(((i64*)s)[0] = i);
  0;});}));
  }
  
  static i64 body(i64 env,i64 state_stub) {
  return(((i64(*)(i64))countdown)(state_stub));
  }
  
  static i64 run(i64 n) {
  return(({i64 s = (i64)(({i64 temp = (i64)malloc(1 * sizeof(i64));
  ((i64*)temp)[0] = (i64)n;
  temp;
  }));
  HANDLE(body, ({TAIL, get}, {TAIL, set}), (s));}));
  }
  
  int main(int argc, char *argv[]) {
  init_stack_pool();
  i64 __res__ = ({i64 arg1 = (i64)(((i64)(readInt())));
  ({i64 arg2 = (i64)(((i64(*)(i64))run)(arg1));
  ({i64 _ = (i64)(((i64)(printInt((int64_t)arg2))));
  0;});});});
  destroy_stack_pool();
  return((int)__res__);
  }
  
