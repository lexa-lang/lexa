  $ lexa ../../benchmarks/lexa/resume_nontail_2/main.lx -o main.c
  $ cat main.c
  #include <stdint.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include <stdbool.h>
  #include <string.h>
  #include <stacktrek.h>
  #include <datastructure.h>
  
  static i64 __handle_body_lifted_6__(i64,i64);
  FAST_SWITCH_DECORATOR
   i64 __operator_stub_lifted_7___operator(i64*,i64,i64);
  static i64 __repeat_lifted_4__(i64,i64);
  static i64 __step_lifted_3__(i64,i64,i64,i64);
  static i64 __run_lifted_2__(i64,i64,i64);
  static i64 __loop_lifted_1__(i64,i64,i64,i64);
  static closure_t* repeat;
  static closure_t* step;
  static closure_t* run;
  static closure_t* loop;
  enum Operator {operator};
  
  static i64 __loop_lifted_1__(i64 __env__,i64 i,i64 s,i64 operator_stub) {
  return(((i == 0) ? s : ({(RAISE(operator_stub, operator, ((i64)i)));
  ((((i64(*)(i64, i64, i64, i64))__loop_lifted_1__)(0,(i - 1),s,operator_stub)) + 1);})));
  }
  
  static i64 __run_lifted_2__(i64 __env__,i64 n,i64 s) {
  return((HANDLE(__handle_body_lifted_6__, ({SINGLESHOT, __operator_stub_lifted_7___operator}), ((i64)loop, (i64)n, (i64)s))));
  }
  
  static i64 __step_lifted_3__(i64 __env__,i64 l,i64 s,i64 n) {
  return(((l == 0) ? s : (({__attribute__((musttail))
   return ((i64(*)(i64, i64, i64, i64))__step_lifted_3__)(0,(l - 1),(((i64(*)(i64, i64, i64))__run_lifted_2__)(0,n,s)),n); 0;}))));
  }
  
  static i64 __repeat_lifted_4__(i64 __env__,i64 n) {
  return((((i64(*)(i64, i64, i64, i64))__step_lifted_3__)(0,1000,0,n)));
  }
  
  int main(int argc, char *argv[]) {
  init_stack_pool();
  repeat = xmalloc(sizeof(closure_t));
  repeat->func_pointer = (i64)__repeat_lifted_4__;
  repeat->env = (i64)NULL;
  step = xmalloc(sizeof(closure_t));
  step->func_pointer = (i64)__step_lifted_3__;
  step->env = (i64)NULL;
  run = xmalloc(sizeof(closure_t));
  run->func_pointer = (i64)__run_lifted_2__;
  run->env = (i64)NULL;
  loop = xmalloc(sizeof(closure_t));
  loop->func_pointer = (i64)__loop_lifted_1__;
  loop->env = (i64)NULL;
  
  i64 __res__ = ({(((i64)(printInt((int64_t)(((i64(*)(i64, i64))__repeat_lifted_4__)(0,(((i64)(readInt())))))))));
  0;});
  destroy_stack_pool();
  return((int)__res__);}
  FAST_SWITCH_DECORATOR
   i64 __operator_stub_lifted_7___operator(i64* __env__,i64 x,i64 k) {
  return(({i64 loop = (i64)(((i64*)__env__)[0]);
  ({i64 n = (i64)(((i64*)__env__)[1]);
  ({i64 s = (i64)(((i64*)__env__)[2]);
  ({i64 y = (i64)(FINAL_THROW(k, 0));
  ((((i64)(mathAbs((int64_t)((x - (503 * y)) + 37))))) % 1009);});});});}));
  }
  
  static i64 __handle_body_lifted_6__(i64 __env__,i64 operator_stub) {
  return(({i64 loop = (i64)(((i64*)__env__)[0]);
  ({i64 n = (i64)(((i64*)__env__)[1]);
  ({i64 s = (i64)(((i64*)__env__)[2]);
  (((i64(*)(i64, i64, i64, i64))__loop_lifted_1__)(0,n,s,operator_stub));});});}));
  }
  
