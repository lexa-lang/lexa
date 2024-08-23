  $ sstal ../lexi_snippets/tail_if.lx -o main.c
  $ cat main.c
  #include <stdint.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include <stdbool.h>
  #include <string.h>
  #include <defs.h>
  #include <datastructure.h>
  
  static i64 __foo_lifted_3__(i64,i64);
  static i64 __bar_lifted_2__(i64,i64);
  static closure_t* foo;
  static closure_t* bar;
  int main(int argc, char *argv[]) {
  init_stack_pool();
  foo = malloc(sizeof(closure_t));
  foo->func_pointer = (i64)__foo_lifted_3__;
  foo->env = (i64)NULL;
  bar = malloc(sizeof(closure_t));
  bar->func_pointer = (i64)__bar_lifted_2__;
  bar->env = (i64)NULL;
  
  i64 __res__ = ({i64 _ = (i64)(((i64)(printInt((int64_t)(((i64(*)(i64, i64))__bar_lifted_2__)(0,42))))));
  ({i64 _ = (i64)(((i64)(printInt((int64_t)(((i64(*)(i64, i64))__foo_lifted_3__)(0,42))))));
  0;});});
  destroy_stack_pool();
  return((int)__res__);}
  static i64 __bar_lifted_2__(i64 __env__,i64 i) {
  return(((i < 2) ? i : ((i % 2) ? (({__attribute__((musttail))
   return ((i64(*)(i64, i64))__bar_lifted_2__)(0,(i / 2)); 0;})) : (1 + (((i64(*)(i64, i64))__bar_lifted_2__)(0,((3 * i) + 1)))))));
  }
  
  static i64 __foo_lifted_3__(i64 __env__,i64 i) {
  return(((i < 2) ? i : ((i % 2) ? (({__attribute__((musttail))
   return ((i64(*)(i64, i64))__foo_lifted_3__)(0,(i / 2)); 0;})) : (({__attribute__((musttail))
   return ((i64(*)(i64, i64))__foo_lifted_3__)(0,((3 * i) + 1)); 0;})))));
  }
  
