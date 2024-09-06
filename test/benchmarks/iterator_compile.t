  $ lexa ../../benchmarks/lexa/iterator/main.lx -o main.c
  $ cat main.c
  #include <stdint.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include <stdbool.h>
  #include <string.h>
  #include <stacktrek.h>
  #include <datastructure.h>
  
  static i64 __handle_body_lifted_4__(i64,i64);
   i64 __emit_stub_lifted_5___emit(i64*,i64);
  static i64 __run_lifted_2__(i64,i64);
  static i64 __range_lifted_1__(i64,i64,i64,i64);
  static closure_t* run;
  static closure_t* range;
  enum Emit {emit};
  
  static i64 __range_lifted_1__(i64 __env__,i64 l,i64 u,i64 emit_stub) {
  return(((l > u) ? 0 : ({(RAISE(emit_stub, emit, ((i64)l)));
  (({__attribute__((musttail))
   return ((i64(*)(i64, i64, i64, i64))__range_lifted_1__)((i64)0, (i64)(l + 1), (i64)u, (i64)emit_stub); 0;}));})));
  }
  
  static i64 __run_lifted_2__(i64 __env__,i64 n) {
  return(({i64 s = (i64)(({i64 __field_0__ = (i64)0;
  i64* __newref__ = xmalloc(1 * sizeof(i64));
  __newref__[0] = __field_0__;
  (i64)__newref__;}));
  ({(HANDLE(__handle_body_lifted_4__, ({TAIL, __emit_stub_lifted_5___emit}), ((i64)n, (i64)range, (i64)s)));
  (((i64*)s)[0]);});}));
  }
  
  int main(int argc, char *argv[]) {
  init_stack_pool();
  run = xmalloc(sizeof(closure_t));
  run->func_pointer = (i64)__run_lifted_2__;
  run->env = (i64)NULL;
  range = xmalloc(sizeof(closure_t));
  range->func_pointer = (i64)__range_lifted_1__;
  range->env = (i64)NULL;
  
  i64 __res__ = ({(((i64)(printInt((int64_t)(((i64(*)(i64, i64))__run_lifted_2__)((i64)0, (i64)(((i64)(readInt())))))))));
  0;});
  destroy_stack_pool();
  return((int)__res__);}
   i64 __emit_stub_lifted_5___emit(i64* __env__,i64 e) {
  return(({i64 n = (i64)(((i64*)__env__)[0]);
  ({i64 range = (i64)(((i64*)__env__)[1]);
  ({i64 s = (i64)(((i64*)__env__)[2]);
  ({(((i64*)s)[0] = ((((i64*)s)[0]) + e));
  0;});});});}));
  }
  
  static i64 __handle_body_lifted_4__(i64 __env__,i64 emit_stub) {
  return(({i64 n = (i64)(((i64*)__env__)[0]);
  ({i64 range = (i64)(((i64*)__env__)[1]);
  ({i64 s = (i64)(((i64*)__env__)[2]);
  (((i64(*)(i64, i64, i64, i64))__range_lifted_1__)((i64)0, (i64)0, (i64)n, (i64)emit_stub));});});}));
  }
  
