  $ sstal ../lexi_snippets/adt/tree.lx -o main.c
  $ cat main.c
  #include <stdint.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include <stdbool.h>
  #include <string.h>
  #include <defs.h>
  #include <datastructure.h>
  
  static i64 __traverse_lifted_3__(i64,i64);
  static i64 __make_lifted_2__(i64,i64);
  static closure_t* traverse;
  static closure_t* make;
  enum __tree_tag__ {
  Nil,
  Node,
  };
  
  
  typedef struct tree {
  enum __tree_tag__ tag;
  union {
  i64 Nil[0];
  i64 Node[3];
  };
  } tree;
  
  int main(int argc, char *argv[]) {
  init_stack_pool();
  traverse = malloc(sizeof(closure_t));
  traverse->func_pointer = (i64)__traverse_lifted_3__;
  traverse->env = (i64)NULL;
  make = malloc(sizeof(closure_t));
  make->func_pointer = (i64)__make_lifted_2__;
  make->env = (i64)NULL;
  
  i64 __res__ = ({i64 t = (i64)(((i64(*)(i64, i64))__make_lifted_2__)(0,(((i64)(readInt())))));
  ({(((i64(*)(i64, i64))__traverse_lifted_3__)(0,t));
  0;});});
  destroy_stack_pool();
  return((int)__res__);}
  static i64 __make_lifted_2__(i64 __env__,i64 i) {
  return(((i == 0) ? (({
  
  tree* __t__ = (tree*)xmalloc(sizeof(tree));
  __t__->tag = Nil;
  
  (i64)__t__;})
  ) : (({
  i64 __arg_0__ = (i64)i;
  i64 __arg_1__ = (i64)(((i64(*)(i64, i64))__make_lifted_2__)(0,(i - 1)));
  i64 __arg_2__ = (i64)(((i64(*)(i64, i64))__make_lifted_2__)(0,(i - 1)));
  
  tree* __t__ = (tree*)xmalloc(sizeof(tree));
  __t__->tag = Node;
  __t__->Node[0] = __arg_0__;
  __t__->Node[1] = __arg_1__;
  __t__->Node[2] = __arg_2__;
  
  (i64)__t__;})
  )));
  }
  
  static i64 __traverse_lifted_3__(i64 __env__,i64 t) {
  return((({i64 __match_res__;tree* __expr_res__=(tree*)t;
  if (__expr_res__->tag == Nil) {__match_res__=({
  0;});}
  else if (__expr_res__->tag == Node) {__match_res__=({i64 i = (i64)(__expr_res__->Node[0]);
  i64 l = (i64)(__expr_res__->Node[1]);
  i64 r = (i64)(__expr_res__->Node[2]);
  
  ({(((i64)(printInt((int64_t)i))));
  ({(((i64(*)(i64, i64))__traverse_lifted_3__)(0,l));
  ({(((i64(*)(i64, i64))__traverse_lifted_3__)(0,r));
  0;});});});});}
  __match_res__;})));
  }
  
