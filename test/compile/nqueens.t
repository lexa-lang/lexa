  $ sstal ../lexi/nqueens/main.ir -o main.c
  $ cat main.c
  #include <stdint.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include <stdbool.h>
  #include <string.h>
  #include <defs.h>
  #include <datastructure.h>
  
  FAST_SWITCH_DECORATOR
   i64 pick(i64*,i64,i64);
   i64 fail(i64*,i64);
  static i64 __loop_lifted_4__(i64,i64,i64,i64,i64);
  static i64 body(i64,i64);
  static i64 __run_lifted_3__(i64,i64);
  static i64 __place_lifted_2__(i64,i64,i64,i64);
  static i64 __safe_lifted_1__(i64,i64,i64,i64);
  closure_t* loop;
  closure_t* run;
  closure_t* place;
  closure_t* safe;
  
  static i64 __safe_lifted_1__(i64 __env__,i64 queen,i64 diag,i64 xs) {
  return(({i64 is_empty = (i64)(((i64)(listIsEmpty((node_t*)xs))));
  (is_empty ? 1 : ({i64 q = (i64)(((i64)(listHead((node_t*)xs))));
  ({i64 qs = (i64)(((i64)(listTail((node_t*)xs))));
  ({i64 cond1 = (i64)(queen != q);
  ({i64 t1 = (i64)(q + diag);
  ({i64 cond2 = (i64)(queen != t1);
  ({i64 t2 = (i64)(q - diag);
  ({i64 cond3 = (i64)(queen != t2);
  ({i64 cond12 = (i64)(((i64)(boolAnd((int64_t)cond1, (int64_t)cond2))));
  ({i64 cond123 = (i64)(((i64)(boolAnd((int64_t)cond12, (int64_t)cond3))));
  (cond123 ? ({i64 diag_inc = (i64)(diag + 1);
  (({closure_t* __clo__ = (closure_t*)safe;
  i64 __f__ = (i64)(__clo__->func_pointer);
  i64 __env__ = (i64)(__clo__->env);
  ((i64(*)(i64, i64, i64, i64))__f__)(__env__,queen,diag_inc,qs);
  }));}) : 0);});});});});});});});});}));}));
  }
  
  static i64 __place_lifted_2__(i64 __env__,i64 size,i64 column,i64 search_stub) {
  return(({i64 is_zero = (i64)(column == 0);
  (is_zero ? (((i64)(listEnd()))) : ({i64 column_dec = (i64)(column - 1);
  ({i64 rest = (i64)(({closure_t* __clo__ = (closure_t*)place;
  i64 __f__ = (i64)(__clo__->func_pointer);
  i64 __env__ = (i64)(__clo__->env);
  ((i64(*)(i64, i64, i64, i64))__f__)(__env__,size,column_dec,search_stub);
  }));
  ({i64 next = (i64)(RAISE(search_stub, 0, (size)));
  ({i64 is_safe = (i64)(({closure_t* __clo__ = (closure_t*)safe;
  i64 __f__ = (i64)(__clo__->func_pointer);
  i64 __env__ = (i64)(__clo__->env);
  ((i64(*)(i64, i64, i64, i64))__f__)(__env__,next,1,rest);
  }));
  (is_safe ? ({i64 head = (i64)(((i64)(listNode((int64_t)next, (node_t*)rest))));
  head;}) : (RAISE(search_stub, 1, (0))));});});});}));}));
  }
  
  static i64 __run_lifted_3__(i64 __env__,i64 n) {
  return((HANDLE(body, ({MULTISHOT, pick}, {ABORT, fail}), (n))));
  }
  
  static i64 body(i64 env,i64 search_stub) {
  return(({i64 n = (i64)(((i64*)env)[0]);
  ({i64 _ = (i64)(({closure_t* __clo__ = (closure_t*)place;
  i64 __f__ = (i64)(__clo__->func_pointer);
  i64 __env__ = (i64)(__clo__->env);
  ((i64(*)(i64, i64, i64, i64))__f__)(__env__,n,n,search_stub);
  }));
  1;});}));
  }
  
  static i64 __loop_lifted_4__(i64 __env__,i64 i,i64 a,i64 size,i64 k) {
  return(({i64 cond = (i64)(i == size);
  (cond ? ({i64 r = (i64)(FINAL_THROW(k, i));
  (a + r);}) : ({i64 r = (i64)(THROW(k, i));
  ({i64 arg1 = (i64)(i + 1);
  ({i64 arg2 = (i64)(a + r);
  (({closure_t* __clo__ = (closure_t*)loop;
  i64 __f__ = (i64)(__clo__->func_pointer);
  i64 __env__ = (i64)(__clo__->env);
  ((i64(*)(i64, i64, i64, i64, i64))__f__)(__env__,arg1,arg2,size,k);
  }));});});}));}));
  }
  
   i64 fail(i64* env,i64 _) {
  return(0);
  }
  
  FAST_SWITCH_DECORATOR
   i64 pick(i64* env,i64 size,i64 k) {
  return((({closure_t* __clo__ = (closure_t*)loop;
  i64 __f__ = (i64)(__clo__->func_pointer);
  i64 __env__ = (i64)(__clo__->env);
  ((i64(*)(i64, i64, i64, i64, i64))__f__)(__env__,1,0,size,k);
  })));
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
  ({i64 run_res = (i64)(({closure_t* __clo__ = (closure_t*)run;
  i64 __f__ = (i64)(__clo__->func_pointer);
  i64 __env__ = (i64)(__clo__->env);
  ((i64(*)(i64, i64))__f__)(__env__,n);
  }));
  ({i64 _ = (i64)(((i64)(printInt((int64_t)run_res))));
  0;});});});
  destroy_stack_pool();
  return((int)__res__);}
