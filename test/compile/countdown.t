  $ sstal ../lexi/countdown/main.ir -o main.c
  $ cat main.c
  #include <stdint.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include <stdbool.h>
  #include <string.h>
  #include <defs.h>
  #include <datastructure.h>
  
  static i64 __run_lifted_2__(i64,i64);
  static i64 body(i64,i64);
   i64 state_set(i64*,i64);
   i64 state_get(i64*,i64);
  static i64 __countdown_lifted_1__(i64,i64);
  closure_t* run;
  closure_t* countdown;
  
  static i64 __countdown_lifted_1__(i64 __env__,i64 state_stub) {
  return(({i64 i = (i64)(RAISE(state_stub, 0, (0)));
  ((i == 0) ? i : ({i64 _ = (i64)(RAISE(state_stub, 1, (i-1)));
  (({closure_t* __clo__ = (closure_t*)countdown;
  i64 __f__ = (i64)(__clo__->func_pointer);
  i64 __env__ = (i64)(__clo__->env);
  ((i64(*)(i64, i64))__f__)(__env__,state_stub);
  }));}));}));
  }
  
   i64 state_get(i64* env,i64 _) {
  return((((i64*)(((i64*)env)[0]))[0]));
  }
  
   i64 state_set(i64* env,i64 i) {
  return(({i64 _ = (i64)(((i64*)(((i64*)env)[0]))[0] = i);
  0;}));
  }
  
  static i64 body(i64 env,i64 state_stub) {
  return((({closure_t* __clo__ = (closure_t*)countdown;
  i64 __f__ = (i64)(__clo__->func_pointer);
  i64 __env__ = (i64)(__clo__->env);
  ((i64(*)(i64, i64))__f__)(__env__,state_stub);
  })));
  }
  
  static i64 __run_lifted_2__(i64 __env__,i64 n) {
  return(({i64 s = (i64)(({i64 temp = (i64)malloc(1 * sizeof(i64));
  ((i64*)temp)[0] = (i64)n;
  temp;
  }));
  (HANDLE(body, ({TAIL, state_get}, {TAIL, state_set}), (s)));}));
  }
  
  int main(int argc, char *argv[]) {
  init_stack_pool();
  run = malloc(sizeof(closure_t));
  run->func_pointer = (i64)__run_lifted_2__;
  run->env = (i64)NULL;
  countdown = malloc(sizeof(closure_t));
  countdown->func_pointer = (i64)__countdown_lifted_1__;
  countdown->env = (i64)NULL;
  
  i64 __res__ = ({i64 _ = (i64)(((i64)(printInt((int64_t)(({closure_t* __clo__ = (closure_t*)run;
  i64 __f__ = (i64)(__clo__->func_pointer);
  i64 __env__ = (i64)(__clo__->env);
  ((i64(*)(i64, i64))__f__)(__env__,(((i64)(readInt()))));
  }))))));
  0;});
  destroy_stack_pool();
  return((int)__res__);}
