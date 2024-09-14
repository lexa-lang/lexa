  $ lexa ../../benchmarks/lexa/generator/main.lx -o main.c
  $ cat main.c
  #include <stdint.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include <stdbool.h>
  #include <string.h>
  #include <stacktrek.h>
  #include <datastructure.h>
  
  static i64 __handle_body_lifted_7__(i64,i64);
  FAST_SWITCH_DECORATOR
   i64 __yield_stub_lifted_8___yield(i64*,i64,i64);
  static i64 __fun_lifted_9__(i64,i64);
  static i64 __run_lifted_5__(i64,i64);
  static i64 __sum_lifted_4__(i64,i64,i64);
  static i64 __generate_lifted_3__(i64,i64);
  static i64 __iterate_lifted_2__(i64,i64,i64);
  static i64 __make_lifted_1__(i64,i64);
  static closure_t* run;
  static closure_t* sum;
  static closure_t* generate;
  static closure_t* iterate;
  static closure_t* make;
  enum Yield {yield};
  
  enum __tree_tag__ {
  Leaf,
  Node,
  };
  
  
  typedef struct tree {
  enum __tree_tag__ tag;
  union {
  i64 Leaf[0];
  i64 Node[3];
  };
  } tree;
  
  enum __generator_tag__ {
  Empty,
  Thunk,
  };
  
  
  typedef struct generator {
  enum __generator_tag__ tag;
  union {
  i64 Empty[0];
  i64 Thunk[2];
  };
  } generator;
  
  static i64 __make_lifted_1__(i64 __env__,i64 n) {
  return(((n == 0) ? (({
  
  tree* __t__ = (tree*)xmalloc(sizeof(tree));
  __t__->tag = Leaf;
  
  (i64)__t__;})
  ) : ({i64 t = (i64)(((i64(*)(i64, i64))__make_lifted_1__)((i64)0, (i64)(n - 1)));
  (({
  i64 __arg_0__ = (i64)n;
  i64 __arg_1__ = (i64)t;
  i64 __arg_2__ = (i64)t;
  
  tree* __t__ = (tree*)xmalloc(sizeof(tree));
  __t__->tag = Node;
  __t__->Node[0] = __arg_0__;
  __t__->Node[1] = __arg_1__;
  __t__->Node[2] = __arg_2__;
  
  (i64)__t__;})
  );})));
  }
  
  static i64 __iterate_lifted_2__(i64 __env__,i64 t,i64 yield_stub) {
  return((({i64 __match_res__;tree* __expr_res__=(tree*)t;
  if (__expr_res__->tag == Leaf) {__match_res__=({
  0;});}
  else if (__expr_res__->tag == Node) {__match_res__=({i64 value = (i64)(__expr_res__->Node[0]);
  i64 left = (i64)(__expr_res__->Node[1]);
  i64 right = (i64)(__expr_res__->Node[2]);
  
  ({(((i64(*)(i64, i64, i64))__iterate_lifted_2__)((i64)0, (i64)left, (i64)yield_stub));
  ({(RAISE(yield_stub, yield, ((i64)value)));
  (((i64(*)(i64, i64, i64))__iterate_lifted_2__)((i64)0, (i64)right, (i64)yield_stub));});});});}
  __match_res__;})));
  }
  
  static i64 __generate_lifted_3__(i64 __env__,i64 f) {
  return((HANDLE(__handle_body_lifted_7__, ({SINGLESHOT, __yield_stub_lifted_8___yield}), ((i64)f))));
  }
  
  static i64 __sum_lifted_4__(i64 __env__,i64 a,i64 g) {
  return((({i64 __match_res__;generator* __expr_res__=(generator*)g;
  if (__expr_res__->tag == Empty) {__match_res__=({
  a;});}
  else if (__expr_res__->tag == Thunk) {__match_res__=({i64 v = (i64)(__expr_res__->Thunk[0]);
  i64 f = (i64)(__expr_res__->Thunk[1]);
  
  (((i64(*)(i64, i64, i64))__sum_lifted_4__)((i64)0, (i64)(v + a), (i64)(FINAL_THROW(f, 0))));});}
  __match_res__;})));
  }
  
  static i64 __run_lifted_5__(i64 __env__,i64 n) {
  return(({i64 f = (i64)(({closure_t* __c__ = xmalloc(sizeof(closure_t));
  __c__->func_pointer = (i64)__fun_lifted_9__;
  __c__->env = (i64)xmalloc(3 * sizeof(i64));
  ((i64*)(__c__->env))[0] = (i64)iterate;
  ((i64*)(__c__->env))[1] = (i64)make;
  ((i64*)(__c__->env))[2] = (i64)n;
  (i64)__c__;}));
  (((i64(*)(i64, i64, i64))__sum_lifted_4__)((i64)0, (i64)0, (i64)(((i64(*)(i64, i64))__generate_lifted_3__)((i64)0, (i64)f))));}));
  }
  
  int main(int argc, char *argv[]) {
  init_stack_pool();
  run = xmalloc(sizeof(closure_t));
  run->func_pointer = (i64)__run_lifted_5__;
  run->env = (i64)NULL;
  sum = xmalloc(sizeof(closure_t));
  sum->func_pointer = (i64)__sum_lifted_4__;
  sum->env = (i64)NULL;
  generate = xmalloc(sizeof(closure_t));
  generate->func_pointer = (i64)__generate_lifted_3__;
  generate->env = (i64)NULL;
  iterate = xmalloc(sizeof(closure_t));
  iterate->func_pointer = (i64)__iterate_lifted_2__;
  iterate->env = (i64)NULL;
  make = xmalloc(sizeof(closure_t));
  make->func_pointer = (i64)__make_lifted_1__;
  make->env = (i64)NULL;
  
  i64 __res__ = ({((i64)(printInt((int64_t)(((i64(*)(i64, i64))__run_lifted_5__)((i64)0, (i64)((i64)(readInt())))))));
  0;});
  destroy_stack_pool();
  return((int)__res__);}
  static i64 __fun_lifted_9__(i64 __env__,i64 yield_stub) {
  return(({i64 iterate = (i64)(((i64*)__env__)[0]);
  ({i64 make = (i64)(((i64*)__env__)[1]);
  ({i64 n = (i64)(((i64*)__env__)[2]);
  (((i64(*)(i64, i64, i64))__iterate_lifted_2__)((i64)0, (i64)(((i64(*)(i64, i64))__make_lifted_1__)((i64)0, (i64)n)), (i64)yield_stub));});});}));
  }
  
  FAST_SWITCH_DECORATOR
   i64 __yield_stub_lifted_8___yield(i64* __env__,i64 x,i64 k) {
  return(({i64 f = (i64)(((i64*)__env__)[0]);
  (({
  i64 __arg_0__ = (i64)x;
  i64 __arg_1__ = (i64)k;
  
  generator* __t__ = (generator*)xmalloc(sizeof(generator));
  __t__->tag = Thunk;
  __t__->Thunk[0] = __arg_0__;
  __t__->Thunk[1] = __arg_1__;
  
  (i64)__t__;})
  );}));
  }
  
  static i64 __handle_body_lifted_7__(i64 __env__,i64 yield_stub) {
  return(({i64 f = (i64)(((i64*)__env__)[0]);
  ({(({closure_t* __clo__ = (closure_t*)f;
  i64 __f__ = (i64)(__clo__->func_pointer);
  i64 __env__ = (i64)(__clo__->env);
  ((i64(*)(i64, i64))__f__)(__env__,yield_stub);
  }));
  (({
  
  generator* __t__ = (generator*)xmalloc(sizeof(generator));
  __t__->tag = Empty;
  
  (i64)__t__;})
  );});}));
  }
  
