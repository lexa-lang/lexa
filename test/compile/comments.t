  $ lexa ../lexa_snippets/comments.lx -o main.c
  $ cat main.c
  #include <stdint.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include <stdbool.h>
  #include <string.h>
  #include <stacktrek.h>
  #include <datastructure.h>
  
  static i64 __fun_lifted_3__(i64,i64);
  static i64 __make_adder_lifted_1__(i64,i64);
  static closure_t* make_adder;
  static i64 __make_adder_lifted_1__(i64 __env__,i64 a) {
  return(({i64 res = (i64)(({closure_t* __c__ = xmalloc(sizeof(closure_t));
  __c__->func_pointer = (i64)__fun_lifted_3__;
  __c__->env = (i64)xmalloc(1 * sizeof(i64));
  ((i64*)(__c__->env))[0] = (i64)a;
  (i64)__c__;}));
  res;}));
  }
  
  int main(int argc, char *argv[]) {
  init_stack_pool();
  make_adder = xmalloc(sizeof(closure_t));
  make_adder->func_pointer = (i64)__make_adder_lifted_1__;
  make_adder->env = (i64)NULL;
  
  i64 __res__ = ({i64 adder5 = (i64)(((i64(*)(i64, i64))__make_adder_lifted_1__)((i64)0, (i64)5));
  ({i64 adder10 = (i64)(((i64(*)(i64, i64))__make_adder_lifted_1__)((i64)0, (i64)10));
  ({i64 _ = (i64)((i64)(printInt((int64_t)(({closure_t* __clo__ = (closure_t*)adder5;
  i64 __f__ = (i64)(__clo__->func_pointer);
  i64 __env__ = (i64)(__clo__->env);
  ((i64(*)(i64, i64))__f__)(__env__,7);
  })))));
  ({i64 _ = (i64)((i64)(printInt((int64_t)(({closure_t* __clo__ = (closure_t*)adder10;
  i64 __f__ = (i64)(__clo__->func_pointer);
  i64 __env__ = (i64)(__clo__->env);
  ((i64(*)(i64, i64))__f__)(__env__,7);
  })))));
  0;});});});});
  destroy_stack_pool();
  return((int)__res__);}
  static i64 __fun_lifted_3__(i64 __env__,i64 b) {
  return(({i64 a = (i64)(((i64*)__env__)[0]);
  (a + b);}));
  }
  
