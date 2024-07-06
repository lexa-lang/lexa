  $ sstal ../lexi/interruptible_iterator/main.ir -o main.c
  $ cat main.c
  #include <stdint.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include <stdbool.h>
  #include <string.h>
  #include <defs.h>
  #include <datastructure.h>
  
  static i64 __repeat_lifted_9__(i64,i64);
  static i64 __step_lifted_8__(i64,i64,i64,i64);
  static i64 __run_lifted_7__(i64,i64);
  static i64 __listSum_lifted_6__(i64,i64,i64);
   i64 behead_main_behead(i64*,i64);
  static i64 body_main_1(i64,i64);
   i64 yield_main_yield(i64*,i64,i64,i64);
  static i64 body_main_2(i64,i64);
  static i64 __loop_lifted_3__(i64,i64,i64,i64);
   i64 loop_behead_behead(i64*,i64);
  static i64 loop_body_2(i64,i64);
   i64 replace_loop_replace(i64*,i64);
  static i64 loop_body_1(i64,i64);
  static closure_t* repeat;
  static closure_t* step;
  static closure_t* run;
  static closure_t* listSum;
  static closure_t* loop;
  enum Yield {yield};
  
  enum Replace {replace};
  
  enum Behead {behead};
  
  static i64 loop_body_1(i64 env,i64 replace_stub) {
  return(({i64 it = (i64)(((i64*)env)[0]);
  ({i64 yield_stub = (i64)(((i64*)env)[1]);
  ({i64 behead_stub = (i64)(((i64*)env)[2]);
  ({i64 v = (i64)(((i64)(listHead((node_t*)it))));
  (RAISE(yield_stub, yield, (v,behead_stub,replace_stub)));});});});}));
  }
  
   i64 replace_loop_replace(i64* env,i64 x) {
  return(({i64 it = (i64)(((i64*)env)[0]);
  (((i64)(listSetHead((node_t*)it, (int64_t)x))));}));
  }
  
  static i64 loop_body_2(i64 env,i64 behead_stub) {
  return(({i64 it_tail = (i64)(((i64*)env)[0]);
  ({i64 yield_stub = (i64)(((i64*)env)[1]);
  (((i64(*)(i64, i64, i64, i64))__loop_lifted_3__)(0,it_tail,yield_stub,behead_stub));});}));
  }
  
   i64 loop_behead_behead(i64* env,i64 _) {
  return(({i64 it = (i64)(((i64*)env)[0]);
  ({i64 beheaded = (i64)(((i64*)env)[2]);
  (((i64*)beheaded)[0] = 1);});}));
  }
  
  static i64 __loop_lifted_3__(i64 __env__,i64 it,i64 yield_stub,i64 behead_stub) {
  return(({i64 _ = (i64)(HANDLE(loop_body_1, ({TAIL, replace_loop_replace}), (it, yield_stub, behead_stub)));
  ({i64 it_tail = (i64)(((i64)(listTail((node_t*)it))));
  ({i64 beheaded = (i64)(({i64 temp = (i64)malloc(1 * sizeof(i64));
  ((i64*)temp)[0] = (i64)0;
  temp;
  }));
  ({i64 newtl = (i64)((((i64)(listIsEmpty((node_t*)it_tail)))) ? (((i64)(listEnd()))) : (HANDLE(loop_body_2, ({TAIL, loop_behead_behead}), (it_tail, yield_stub, beheaded))));
  ({i64 tobehead = (i64)(((i64*)beheaded)[0]);
  ({i64 _ = (i64)(tobehead ? ({i64 tailtail = (i64)(((i64)(listTail((node_t*)newtl))));
  (((i64)(listSetTail((node_t*)it, (node_t*)tailtail))));}) : 0);
  it;});});});});});}));
  }
  
  static i64 body_main_2(i64 env,i64 yield_stub) {
  return(({i64 behead_stub = (i64)(((i64*)env)[0]);
  ({i64 l = (i64)(((i64*)env)[1]);
  (((i64(*)(i64, i64, i64, i64))__loop_lifted_3__)(0,l,yield_stub,behead_stub));});}));
  }
  
   i64 yield_main_yield(i64* env,i64 x,i64 behead_stub,i64 replace_stub) {
  return(((x < 0) ? (RAISE(behead_stub, behead, (0))) : (RAISE(replace_stub, replace, ((x * 2))))));
  }
  
  static i64 body_main_1(i64 env,i64 behead_stub) {
  return(({i64 l = (i64)(((i64*)env)[0]);
  (HANDLE(body_main_2, ({TAIL, yield_main_yield}), (behead_stub, l)));}));
  }
  
   i64 behead_main_behead(i64* env,i64 _) {
  return(({i64 beheaded = (i64)(((i64*)env)[1]);
  (((i64*)beheaded)[0] = 1);}));
  }
  
  static i64 __listSum_lifted_6__(i64 __env__,i64 l,i64 acc) {
  return(((((i64)(listIsEmpty((node_t*)l)))) ? acc : (({__attribute__((musttail))
   return ((i64(*)(i64, i64, i64))__listSum_lifted_6__)(0,(((i64)(listTail((node_t*)l)))),(acc + (((i64)(listHead((node_t*)l)))))); 0;}))));
  }
  
  static i64 __run_lifted_7__(i64 __env__,i64 n) {
  return(({i64 l = (i64)(((i64)(listRange((int64_t)(0 - n), (int64_t)n))));
  ({i64 beheaded = (i64)(({i64 temp = (i64)malloc(1 * sizeof(i64));
  ((i64*)temp)[0] = (i64)0;
  temp;
  }));
  ({i64 newtl = (i64)(HANDLE(body_main_1, ({TAIL, behead_main_behead}), (l, beheaded)));
  ({i64 tobehead = (i64)(((i64*)beheaded)[0]);
  ({i64 res = (i64)(tobehead ? (((i64)(listTail((node_t*)newtl)))) : newtl);
  (((i64(*)(i64, i64))__listSum_lifted_6__)(0,res));});});});});}));
  }
  
  static i64 __step_lifted_8__(i64 __env__,i64 i,i64 acc,i64 n_jobs) {
  return(((i == 0) ? acc : (({__attribute__((musttail))
   return ((i64(*)(i64, i64, i64, i64))__step_lifted_8__)(0,(i - 1),(acc + (((i64(*)(i64, i64))__run_lifted_7__)(0,n_jobs))),n_jobs); 0;}))));
  }
  
  static i64 __repeat_lifted_9__(i64 __env__,i64 n_jobs) {
  return((((i64(*)(i64, i64, i64, i64))__step_lifted_8__)(0,1000,0,n_jobs)));
  }
  
  int main(int argc, char *argv[]) {
  init_stack_pool();
  repeat = malloc(sizeof(closure_t));
  repeat->func_pointer = (i64)__repeat_lifted_9__;
  repeat->env = (i64)NULL;
  step = malloc(sizeof(closure_t));
  step->func_pointer = (i64)__step_lifted_8__;
  step->env = (i64)NULL;
  run = malloc(sizeof(closure_t));
  run->func_pointer = (i64)__run_lifted_7__;
  run->env = (i64)NULL;
  listSum = malloc(sizeof(closure_t));
  listSum->func_pointer = (i64)__listSum_lifted_6__;
  listSum->env = (i64)NULL;
  loop = malloc(sizeof(closure_t));
  loop->func_pointer = (i64)__loop_lifted_3__;
  loop->env = (i64)NULL;
  
  i64 __res__ = ({i64 arg1 = (i64)(((i64)(readInt())));
  ({i64 arg2 = (i64)(((i64(*)(i64, i64))__repeat_lifted_9__)(0,arg1));
  ({i64 _ = (i64)(((i64)(printInt((int64_t)arg2))));
  0;});});});
  destroy_stack_pool();
  return((int)__res__);}
