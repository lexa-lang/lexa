  $ sstal ../lexi/nqueens/main.ir -o main.c
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
   i64 __search_stub_lifted_7___pick(i64*,i64,i64);
   i64 __search_stub_lifted_7___fail(i64*,i64);
  static i64 __loop_lifted_4__(i64,i64,i64,i64,i64);
  static i64 __run_lifted_3__(i64,i64);
  static i64 __place_lifted_2__(i64,i64,i64,i64);
  static i64 __safe_lifted_1__(i64,i64,i64,i64);
  static closure_t* loop;
  static closure_t* run;
  static closure_t* place;
  static closure_t* safe;
  enum Search {pick,fail};
  
  static i64 __safe_lifted_1__(i64 __env__,i64 queen,i64 diag,i64 xs) {
  return(({i64 is_empty = (i64)(((i64)(listIsEmpty((node_t*)xs))));
  (is_empty ? 1 : ({i64 q = (i64)(((i64)(listHead((node_t*)xs))));
  ({i64 qs = (i64)(((i64)(listTail((node_t*)xs))));
  ((((i64)(boolAnd((int64_t)(((i64)(boolAnd((int64_t)(queen != q), (int64_t)(queen != (q + diag)))))), (int64_t)(queen != (q - diag)))))) ? (({__attribute__((musttail))
   return ((i64(*)(i64, i64, i64, i64))__safe_lifted_1__)(0,queen,(diag + 1),qs); 0;})) : 0);});}));}));
  }
  
  static i64 __place_lifted_2__(i64 __env__,i64 size,i64 column,i64 search_stub) {
  return(((column == 0) ? (((i64)(listEnd()))) : ({i64 rest = (i64)(((i64(*)(i64, i64, i64, i64))__place_lifted_2__)(0,size,(column - 1),search_stub));
  ({i64 next = (i64)(RAISE(search_stub, pick, ((i64)size)));
  ((((i64(*)(i64, i64, i64, i64))__safe_lifted_1__)(0,next,1,rest)) ? (((i64)(listNode((int64_t)next, (node_t*)rest)))) : (RAISE(search_stub, fail, ((i64)0))));});})));
  }
  
  static i64 __run_lifted_3__(i64 __env__,i64 n) {
  return((HANDLE(__handle_body_lifted_6__, ({MULTISHOT, __search_stub_lifted_7___pick}, {ABORT, __search_stub_lifted_7___fail}), ((i64)loop, (i64)n, (i64)place))));
  }
  
  static i64 __loop_lifted_4__(i64 __env__,i64 i,i64 a,i64 size,i64 k) {
  return(((i == size) ? (a + (FINAL_THROW(k, i))) : (({__attribute__((musttail))
   return ((i64(*)(i64, i64, i64, i64, i64))__loop_lifted_4__)(0,(i + 1),(a + (THROW(k, i))),size,k); 0;}))));
  }
  
  int main(int argc, char *argv[]) {
  init_stack_pool();
  loop = malloc(sizeof(closure_t));
  loop->func_pointer = (i64)__loop_lifted_4__;
  loop->env = (i64)NULL;
  run = malloc(sizeof(closure_t));
  run->func_pointer = (i64)__run_lifted_3__;
  run->env = (i64)NULL;
  place = malloc(sizeof(closure_t));
  place->func_pointer = (i64)__place_lifted_2__;
  place->env = (i64)NULL;
  safe = malloc(sizeof(closure_t));
  safe->func_pointer = (i64)__safe_lifted_1__;
  safe->env = (i64)NULL;
  
  i64 __res__ = ({i64 n = (i64)(((i64)(readInt())));
  ({i64 run_res = (i64)(((i64(*)(i64, i64))__run_lifted_3__)(0,n));
  ({(((i64)(printInt((int64_t)run_res))));
  0;});});});
  destroy_stack_pool();
  return((int)__res__);}
   i64 __search_stub_lifted_7___fail(i64* __env__,i64 _) {
  return(({i64 loop = (i64)(((i64*)__env__)[0]);
  ({i64 n = (i64)(((i64*)__env__)[1]);
  ({i64 place = (i64)(((i64*)__env__)[2]);
  0;});});}));
  }
  
  FAST_SWITCH_DECORATOR
   i64 __search_stub_lifted_7___pick(i64* __env__,i64 size,i64 k) {
  return(({i64 loop = (i64)(((i64*)__env__)[0]);
  ({i64 n = (i64)(((i64*)__env__)[1]);
  ({i64 place = (i64)(((i64*)__env__)[2]);
  (((i64(*)(i64, i64, i64, i64, i64))__loop_lifted_4__)(0,1,0,size,k));});});}));
  }
  
  static i64 __handle_body_lifted_6__(i64 __env__,i64 search_stub) {
  return(({i64 loop = (i64)(((i64*)__env__)[0]);
  ({i64 n = (i64)(((i64*)__env__)[1]);
  ({i64 place = (i64)(((i64*)__env__)[2]);
  ({(((i64(*)(i64, i64, i64, i64))__place_lifted_2__)(0,n,n,search_stub));
  1;});});});}));
  }
  
