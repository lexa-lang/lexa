  $ lexa ../lexa_snippets/diff_op_type.lx -o main.c
  $ cat main.c
  #include <stdint.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include <stdbool.h>
  #include <string.h>
  #include <stacktrek.h>
  #include <datastructure.h>
  
  static i64 __handle_body_lifted_5__(i64,i64);
  FAST_SWITCH_DECORATOR
   i64 __state2_stub_lifted_6___set(i64*,i64,i64);
  FAST_SWITCH_DECORATOR
   i64 __state2_stub_lifted_6___get(i64*,i64,i64);
  static i64 __handle_body_lifted_7__(i64,i64);
   i64 __state1_stub_lifted_8___set(i64*,i64);
   i64 __state1_stub_lifted_8___get(i64*,i64);
  static i64 __run_lifted_3__(i64,i64);
  static i64 __body_lifted_2__(i64,i64,i64);
  static i64 __countdown_lifted_1__(i64,i64);
  static closure_t* run;
  static closure_t* body;
  static closure_t* countdown;
  enum State {get,set};
  
  static i64 __countdown_lifted_1__(i64 __env__,i64 state_stub) {
  return(({i64 i = (i64)(RAISE(state_stub, get, ((i64)0)));
  ((i == 0) ? i : ({i64 arg = (i64)(i - 1);
  ({(RAISE(state_stub, set, ((i64)arg)));
  (({__attribute__((musttail))
   return ((i64(*)(i64, i64))__countdown_lifted_1__)((i64)0, (i64)state_stub); 0;}));});}));}));
  }
  
  static i64 __body_lifted_2__(i64 __env__,i64 env,i64 state_stub) {
  return((((i64(*)(i64, i64))__countdown_lifted_1__)((i64)0, (i64)state_stub)));
  }
  
  static i64 __run_lifted_3__(i64 __env__,i64 n) {
  return(({i64 s = (i64)(({i64 __field_0__ = (i64)n;
  i64* __newref__ = xmalloc(1 * sizeof(i64));
  __newref__[0] = __field_0__;
  (i64)__newref__;}));
  ({(HANDLE(__handle_body_lifted_7__, ({TAIL, __state1_stub_lifted_8___get}, {TAIL, __state1_stub_lifted_8___set}), ((i64)countdown, (i64)s)));
  (HANDLE(__handle_body_lifted_5__, ({SINGLESHOT, __state2_stub_lifted_6___get}, {SINGLESHOT, __state2_stub_lifted_6___set}), ((i64)countdown, (i64)s)));});}));
  }
  
  int main(int argc, char *argv[]) {
  init_stack_pool();
  run = xmalloc(sizeof(closure_t));
  run->func_pointer = (i64)__run_lifted_3__;
  run->env = (i64)NULL;
  body = xmalloc(sizeof(closure_t));
  body->func_pointer = (i64)__body_lifted_2__;
  body->env = (i64)NULL;
  countdown = xmalloc(sizeof(closure_t));
  countdown->func_pointer = (i64)__countdown_lifted_1__;
  countdown->env = (i64)NULL;
  
  i64 __res__ = ({i64 arg1 = (i64)((i64)(readInt()));
  ({i64 arg2 = (i64)(((i64(*)(i64, i64))__run_lifted_3__)((i64)0, (i64)arg1));
  ({((i64)(printInt((int64_t)arg2)));
  0;});});});
  destroy_stack_pool();
  return((int)__res__);}
   i64 __state1_stub_lifted_8___get(i64* __env__,i64 _) {
  return(({i64 countdown = (i64)(((i64*)__env__)[0]);
  ({i64 s = (i64)(((i64*)__env__)[1]);
  (((i64*)s)[0]);});}));
  }
  
   i64 __state1_stub_lifted_8___set(i64* __env__,i64 i) {
  return(({i64 countdown = (i64)(((i64*)__env__)[0]);
  ({i64 s = (i64)(((i64*)__env__)[1]);
  ({(((i64*)s)[0] = i);
  0;});});}));
  }
  
  static i64 __handle_body_lifted_7__(i64 __env__,i64 state1_stub) {
  return(({i64 countdown = (i64)(((i64*)__env__)[0]);
  ({i64 s = (i64)(((i64*)__env__)[1]);
  (((i64(*)(i64, i64))__countdown_lifted_1__)((i64)0, (i64)state1_stub));});}));
  }
  
  FAST_SWITCH_DECORATOR
   i64 __state2_stub_lifted_6___get(i64* __env__,i64 _,i64 k) {
  return(({i64 countdown = (i64)(((i64*)__env__)[0]);
  ({i64 s = (i64)(((i64*)__env__)[1]);
  (FINAL_THROW(k, (((i64*)s)[0])));});}));
  }
  
  FAST_SWITCH_DECORATOR
   i64 __state2_stub_lifted_6___set(i64* __env__,i64 i,i64 k) {
  return(({i64 countdown = (i64)(((i64*)__env__)[0]);
  ({i64 s = (i64)(((i64*)__env__)[1]);
  ({(((i64*)s)[0] = i);
  (FINAL_THROW(k, 0));});});}));
  }
  
  static i64 __handle_body_lifted_5__(i64 __env__,i64 state2_stub) {
  return(({i64 countdown = (i64)(((i64*)__env__)[0]);
  ({i64 s = (i64)(((i64*)__env__)[1]);
  (((i64(*)(i64, i64))__countdown_lifted_1__)((i64)0, (i64)state2_stub));});}));
  }
  
