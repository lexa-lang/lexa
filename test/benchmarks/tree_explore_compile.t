  $ sstal ../../benchmarks/lexi/tree_explore/main.lx -o main.c
  $ cat main.c
  #include <stdint.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include <stdbool.h>
  #include <string.h>
  #include <defs.h>
  #include <datastructure.h>
  
  static i64 __list_max_rec_lifted_10__(i64,i64,i64);
  static i64 __handle_body_lifted_11__(i64,i64);
  FAST_SWITCH_DECORATOR
   i64 __choice_stub_lifted_12___choose(i64*,i64,i64);
  static i64 __run_lifted_8__(i64,i64);
  static i64 __loop_lifted_7__(i64,i64,i64,i64);
  static i64 __paths_lifted_6__(i64,i64,i64);
  static i64 __explore_lifted_5__(i64,i64,i64,i64);
  static i64 __make_lifted_4__(i64,i64);
  static i64 __operator_lifted_3__(i64,i64,i64);
  static i64 __list_max_lifted_2__(i64,i64);
  static i64 __append_lifted_1__(i64,i64,i64);
  static closure_t* run;
  static closure_t* loop;
  static closure_t* paths;
  static closure_t* explore;
  static closure_t* make;
  static closure_t* operator;
  static closure_t* list_max;
  static closure_t* append;
  enum Choice {choose};
  
  enum __list_tag__ {
  Nil,
  Cons,
  };
  
  
  typedef struct list {
  enum __list_tag__ tag;
  union {
  i64 Nil[0];
  i64 Cons[2];
  };
  } list;
  
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
  
  static i64 __append_lifted_1__(i64 __env__,i64 l1,i64 l2) {
  return((({i64 __match_res__;list* __expr_res__=(list*)l1;
  if (__expr_res__->tag == Nil) {__match_res__=({
  l2;});}
  else if (__expr_res__->tag == Cons) {__match_res__=({i64 h = (i64)(__expr_res__->Cons[0]);
  i64 t = (i64)(__expr_res__->Cons[1]);
  
  (({
  i64 __arg_0__ = (i64)h;
  i64 __arg_1__ = (i64)(((i64(*)(i64, i64, i64))__append_lifted_1__)(0,t,l2));
  
  list* __t__ = (list*)xmalloc(sizeof(list));
  __t__->tag = Cons;
  __t__->Cons[0] = __arg_0__;
  __t__->Cons[1] = __arg_1__;
  
  (i64)__t__;})
  );});}
  __match_res__;})));
  }
  
  static i64 __list_max_lifted_2__(i64 __env__,i64 l) {
  return(({closure_t* list_max_rec = malloc(sizeof(closure_t));
  
  list_max_rec->env = (i64)malloc(1 * sizeof(i64));
  ((i64*)(list_max_rec->env))[0] = (i64)list_max_rec;
  list_max_rec->func_pointer = (i64)__list_max_rec_lifted_10__;
  
  (({closure_t* __clo__ = (closure_t*)list_max_rec;
  i64 __f__ = (i64)(__clo__->func_pointer);
  i64 __env__ = (i64)(__clo__->env);
  ((i64(*)(i64, i64, i64))__f__)(__env__,l,0);
  }));}));
  }
  
  static i64 __operator_lifted_3__(i64 __env__,i64 x,i64 y) {
  return(((((i64)(mathAbs((int64_t)((x - (503 * y)) + 37))))) % 1009));
  }
  
  static i64 __make_lifted_4__(i64 __env__,i64 n) {
  return(((n == 0) ? (({
  
  tree* __t__ = (tree*)xmalloc(sizeof(tree));
  __t__->tag = Leaf;
  
  (i64)__t__;})
  ) : ({i64 t = (i64)(((i64(*)(i64, i64))__make_lifted_4__)(0,(n - 1)));
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
  
  static i64 __explore_lifted_5__(i64 __env__,i64 state,i64 tre,i64 choice_stub) {
  return((({i64 __match_res__;tree* __expr_res__=(tree*)tre;
  if (__expr_res__->tag == Leaf) {__match_res__=({
  (((i64*)state)[0]);});}
  else if (__expr_res__->tag == Node) {__match_res__=({i64 value = (i64)(__expr_res__->Node[0]);
  i64 left = (i64)(__expr_res__->Node[1]);
  i64 right = (i64)(__expr_res__->Node[2]);
  
  ({i64 next = (i64)((RAISE(choice_stub, choose, ((i64)0))) ? left : right);
  ({(((i64*)state)[0] = (((i64(*)(i64, i64, i64))__operator_lifted_3__)(0,(((i64*)state)[0]),value)));
  (((i64(*)(i64, i64, i64))__operator_lifted_3__)(0,value,(((i64(*)(i64, i64, i64, i64))__explore_lifted_5__)(0,state,next,choice_stub))));});});});}
  __match_res__;})));
  }
  
  static i64 __paths_lifted_6__(i64 __env__,i64 state,i64 tre) {
  return((HANDLE(__handle_body_lifted_11__, ({MULTISHOT, __choice_stub_lifted_12___choose}), ((i64)append, (i64)explore, (i64)state, (i64)tre))));
  }
  
  static i64 __loop_lifted_7__(i64 __env__,i64 state,i64 tre,i64 i) {
  return(((i == 0) ? (((i64*)state)[0]) : ({(((i64*)state)[0] = (((i64(*)(i64, i64))__list_max_lifted_2__)(0,(((i64(*)(i64, i64, i64))__paths_lifted_6__)(0,state,tre)))));
  (({__attribute__((musttail))
   return ((i64(*)(i64, i64, i64, i64))__loop_lifted_7__)(0,state,tre,(i - 1)); 0;}));})));
  }
  
  static i64 __run_lifted_8__(i64 __env__,i64 n) {
  return(({i64 tre = (i64)(((i64(*)(i64, i64))__make_lifted_4__)(0,n));
  ({i64 state = (i64)(({i64 __field_0__ = (i64)0;
  i64* __newref__ = malloc(1 * sizeof(i64));
  __newref__[0] = __field_0__;
  (i64)__newref__;}));
  (((i64(*)(i64, i64, i64, i64))__loop_lifted_7__)(0,state,tre,10));});}));
  }
  
  int main(int argc, char *argv[]) {
  init_stack_pool();
  run = malloc(sizeof(closure_t));
  run->func_pointer = (i64)__run_lifted_8__;
  run->env = (i64)NULL;
  loop = malloc(sizeof(closure_t));
  loop->func_pointer = (i64)__loop_lifted_7__;
  loop->env = (i64)NULL;
  paths = malloc(sizeof(closure_t));
  paths->func_pointer = (i64)__paths_lifted_6__;
  paths->env = (i64)NULL;
  explore = malloc(sizeof(closure_t));
  explore->func_pointer = (i64)__explore_lifted_5__;
  explore->env = (i64)NULL;
  make = malloc(sizeof(closure_t));
  make->func_pointer = (i64)__make_lifted_4__;
  make->env = (i64)NULL;
  operator = malloc(sizeof(closure_t));
  operator->func_pointer = (i64)__operator_lifted_3__;
  operator->env = (i64)NULL;
  list_max = malloc(sizeof(closure_t));
  list_max->func_pointer = (i64)__list_max_lifted_2__;
  list_max->env = (i64)NULL;
  append = malloc(sizeof(closure_t));
  append->func_pointer = (i64)__append_lifted_1__;
  append->env = (i64)NULL;
  
  i64 __res__ = ({i64 n = (i64)(((i64)(readInt())));
  ({i64 res = (i64)(((i64(*)(i64, i64))__run_lifted_8__)(0,n));
  ({(((i64)(printInt((int64_t)res))));
  0;});});});
  destroy_stack_pool();
  return((int)__res__);}
  FAST_SWITCH_DECORATOR
   i64 __choice_stub_lifted_12___choose(i64* __env__,i64 _,i64 k) {
  return(({i64 append = (i64)(((i64*)__env__)[0]);
  ({i64 explore = (i64)(((i64*)__env__)[1]);
  ({i64 state = (i64)(((i64*)__env__)[2]);
  ({i64 tre = (i64)(((i64*)__env__)[3]);
  ({i64 arg1 = (i64)(THROW(k, 1));
  ({i64 arg2 = (i64)(FINAL_THROW(k, 0));
  (((i64(*)(i64, i64, i64))__append_lifted_1__)(0,arg1,arg2));});});});});});}));
  }
  
  static i64 __handle_body_lifted_11__(i64 __env__,i64 choice_stub) {
  return(({i64 append = (i64)(((i64*)__env__)[0]);
  ({i64 explore = (i64)(((i64*)__env__)[1]);
  ({i64 state = (i64)(((i64*)__env__)[2]);
  ({i64 tre = (i64)(((i64*)__env__)[3]);
  (({
  i64 __arg_0__ = (i64)(((i64(*)(i64, i64, i64, i64))__explore_lifted_5__)(0,state,tre,choice_stub));
  i64 __arg_1__ = (i64)(({
  
  list* __t__ = (list*)xmalloc(sizeof(list));
  __t__->tag = Nil;
  
  (i64)__t__;})
  );
  
  list* __t__ = (list*)xmalloc(sizeof(list));
  __t__->tag = Cons;
  __t__->Cons[0] = __arg_0__;
  __t__->Cons[1] = __arg_1__;
  
  (i64)__t__;})
  );});});});}));
  }
  
  static i64 __list_max_rec_lifted_10__(i64 __env__,i64 l,i64 acc) {
  return(({i64 list_max_rec = (i64)(((i64*)__env__)[0]);
  (({i64 __match_res__;list* __expr_res__=(list*)l;
  if (__expr_res__->tag == Nil) {__match_res__=({
  acc;});}
  else if (__expr_res__->tag == Cons) {__match_res__=({i64 h = (i64)(__expr_res__->Cons[0]);
  i64 t = (i64)(__expr_res__->Cons[1]);
  
  ((h > acc) ? (({closure_t* __clo__ = (closure_t*)list_max_rec;
  i64 __f__ = (i64)(__clo__->func_pointer);
  i64 __env__ = (i64)(__clo__->env);
  ((i64(*)(i64, i64, i64))__f__)(__env__,t,h);
  })) : (({closure_t* __clo__ = (closure_t*)list_max_rec;
  i64 __f__ = (i64)(__clo__->func_pointer);
  i64 __env__ = (i64)(__clo__->env);
  ((i64(*)(i64, i64, i64))__f__)(__env__,t,acc);
  })));});}
  __match_res__;}));}));
  }
  
