  $ sstal ../lexi/countdown/main.ir -o main.c
  $ cat main.c
  #include <stdint.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include <stdbool.h>
  #include <string.h>
  #include <defs.h>
  #include <datastructure.h>
  
  static i64 __run_lifted_3__(i64,i64);
  static i64 body(i64,i64);
   i64 state_set(i64*,i64);
   i64 state_get(i64*,i64);
  static i64 __countdown_lifted_1__(i64,i64);
  static closure_t* run;
  static closure_t* countdown;
  enum State {get,set};
  
  static i64 __countdown_lifted_1__(i64 __env__,i64 state_stub) {
  return(({i64 i = (i64)(RAISE(state_stub, get, (0)));
  ((i == 0) ? i : ({i64 _ = (i64)(RAISE(state_stub, set, (i-1)));
  (((i64(*)(i64, i64))__countdown_lifted_1__)(0,state_stub));}));}));
  }
  
   i64 state_get(i64* env,i64 _) {
  return((((i64*)(((i64*)env)[0]))[0]));
  }
  
   i64 state_set(i64* env,i64 i) {
  return(({i64 _ = (i64)(((i64*)(((i64*)env)[0]))[0] = i);
  0;}));
  }
  
  static i64 body(i64 env,i64 state_stub) {
  return((((i64(*)(i64, i64))__countdown_lifted_1__)(0,state_stub)));
  }
  
  static i64 __run_lifted_3__(i64 __env__,i64 n) {
  return(({i64 s = (i64)(({i64 temp = (i64)malloc(1 * sizeof(i64));
  ((i64*)temp)[0] = (i64)n;
  temp;
  }));
  (HANDLE(body, ({TAIL, state_get}, {TAIL, state_set}), (s)));}));
  }
  
  int main(int argc, char *argv[]) {
  init_stack_pool();
  run = malloc(sizeof(closure_t));
  run->func_pointer = (i64)__run_lifted_3__;
  run->env = (i64)NULL;
  countdown = malloc(sizeof(closure_t));
  countdown->func_pointer = (i64)__countdown_lifted_1__;
  countdown->env = (i64)NULL;
  
  i64 __res__ = ({i64 _ = (i64)(((i64)(printInt((int64_t)(((i64(*)(i64, i64))__run_lifted_3__)(0,(((i64)(readInt())))))))));
  0;});
  destroy_stack_pool();
  return((int)__res__);}
