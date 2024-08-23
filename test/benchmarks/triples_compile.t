  $ sstal ../../benchmarks/lexa/triples/main.lx -o main.c
  $ cat main.c
  #include <stdint.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include <stdbool.h>
  #include <string.h>
  #include <defs.h>
  #include <datastructure.h>
  
  static i64 __handle_body_lifted_6__(i64,i64);
  FAST_SWITCH_DECORATOR
   i64 __choice_stub_lifted_7___flip(i64*,i64,i64);
   i64 __choice_stub_lifted_7___fail(i64*,i64);
  static i64 __hash_lifted_4__(i64,i64,i64,i64);
  static i64 __run_lifted_3__(i64,i64,i64);
  static i64 __triple_lifted_2__(i64,i64,i64,i64);
  static i64 __choice_lifted_1__(i64,i64,i64);
  static closure_t* hash;
  static closure_t* run;
  static closure_t* triple;
  static closure_t* choice;
  enum Choice {flip,fail};
  
  static i64 __choice_lifted_1__(i64 __env__,i64 n,i64 choice_stub) {
  return(((n < 1) ? (RAISE(choice_stub, fail, ((i64)0))) : ((RAISE(choice_stub, flip, ((i64)0))) ? n : (({__attribute__((musttail))
   return ((i64(*)(i64, i64, i64))__choice_lifted_1__)(0,(n - 1),choice_stub); 0;})))));
  }
  
  static i64 __triple_lifted_2__(i64 __env__,i64 n,i64 s,i64 choice_stub) {
  return(({i64 i = (i64)(((i64(*)(i64, i64, i64))__choice_lifted_1__)(0,n,choice_stub));
  ({i64 j = (i64)(((i64(*)(i64, i64, i64))__choice_lifted_1__)(0,(i - 1),choice_stub));
  ({i64 k = (i64)(((i64(*)(i64, i64, i64))__choice_lifted_1__)(0,(j - 1),choice_stub));
  ((((i + j) + k) == s) ? (((i64(*)(i64, i64, i64, i64))__hash_lifted_4__)(0,i,j,k)) : (RAISE(choice_stub, fail, ((i64)0))));});});}));
  }
  
  static i64 __run_lifted_3__(i64 __env__,i64 n,i64 s) {
  return((HANDLE(__handle_body_lifted_6__, ({MULTISHOT, __choice_stub_lifted_7___flip}, {ABORT, __choice_stub_lifted_7___fail}), ((i64)n, (i64)s, (i64)triple))));
  }
  
  static i64 __hash_lifted_4__(i64 __env__,i64 a,i64 b,i64 c) {
  return(((((53 * a) + (2809 * b)) + (148877 * c)) % 1000000007));
  }
  
  int main(int argc, char *argv[]) {
  init_stack_pool();
  hash = malloc(sizeof(closure_t));
  hash->func_pointer = (i64)__hash_lifted_4__;
  hash->env = (i64)NULL;
  run = malloc(sizeof(closure_t));
  run->func_pointer = (i64)__run_lifted_3__;
  run->env = (i64)NULL;
  triple = malloc(sizeof(closure_t));
  triple->func_pointer = (i64)__triple_lifted_2__;
  triple->env = (i64)NULL;
  choice = malloc(sizeof(closure_t));
  choice->func_pointer = (i64)__choice_lifted_1__;
  choice->env = (i64)NULL;
  
  i64 __res__ = ({i64 n = (i64)(((i64)(readInt())));
  ({i64 res = (i64)(((i64(*)(i64, i64, i64))__run_lifted_3__)(0,n,n));
  ({(((i64)(printInt((int64_t)res))));
  0;});});});
  destroy_stack_pool();
  return((int)__res__);}
   i64 __choice_stub_lifted_7___fail(i64* __env__,i64 _) {
  return(({i64 n = (i64)(((i64*)__env__)[0]);
  ({i64 s = (i64)(((i64*)__env__)[1]);
  ({i64 triple = (i64)(((i64*)__env__)[2]);
  0;});});}));
  }
  
  FAST_SWITCH_DECORATOR
   i64 __choice_stub_lifted_7___flip(i64* __env__,i64 _,i64 k) {
  return(({i64 n = (i64)(((i64*)__env__)[0]);
  ({i64 s = (i64)(((i64*)__env__)[1]);
  ({i64 triple = (i64)(((i64*)__env__)[2]);
  (((THROW(k, 1)) + (FINAL_THROW(k, 0))) % 1000000007);});});}));
  }
  
  static i64 __handle_body_lifted_6__(i64 __env__,i64 choice_stub) {
  return(({i64 n = (i64)(((i64*)__env__)[0]);
  ({i64 s = (i64)(((i64*)__env__)[1]);
  ({i64 triple = (i64)(((i64*)__env__)[2]);
  (((i64(*)(i64, i64, i64, i64))__triple_lifted_2__)(0,n,s,choice_stub));});});}));
  }
  
