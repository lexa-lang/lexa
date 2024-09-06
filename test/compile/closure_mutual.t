  $ lexa ../lexa_snippets/closure_mutual.lx -o main.c
  $ cat main.c
  #include <stdint.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include <stdbool.h>
  #include <string.h>
  #include <stacktrek.h>
  #include <datastructure.h>
  
  static i64 __is_even_lifted_3__(i64,i64);
  static i64 __is_odd_lifted_4__(i64,i64);
  static i64 __is_even_lifted_1__(i64,i64);
  static closure_t* is_even;
  static i64 __is_even_lifted_1__(i64 __env__,i64 n) {
  return(({closure_t* is_even = xmalloc(sizeof(closure_t));
  closure_t* is_odd = xmalloc(sizeof(closure_t));
  
  is_even->env = (i64)xmalloc(1 * sizeof(i64));
  ((i64*)(is_even->env))[0] = (i64)is_odd;
  is_even->func_pointer = (i64)__is_even_lifted_3__;
  
  is_odd->env = (i64)xmalloc(1 * sizeof(i64));
  ((i64*)(is_odd->env))[0] = (i64)is_even;
  is_odd->func_pointer = (i64)__is_odd_lifted_4__;
  
  (({closure_t* __clo__ = (closure_t*)is_even;
  i64 __f__ = (i64)(__clo__->func_pointer);
  i64 __env__ = (i64)(__clo__->env);
  ((i64(*)(i64, i64))__f__)(__env__,n);
  }));}));
  }
  
  int main(int argc, char *argv[]) {
  init_stack_pool();
  is_even = xmalloc(sizeof(closure_t));
  is_even->func_pointer = (i64)__is_even_lifted_1__;
  is_even->env = (i64)NULL;
  
  i64 __res__ = ({i64 _ = (i64)(((i64)(printInt((int64_t)(((i64(*)(i64, i64))__is_even_lifted_1__)((i64)0, (i64)(((i64)(readInt())))))))));
  0;});
  destroy_stack_pool();
  return((int)__res__);}
  static i64 __is_odd_lifted_4__(i64 __env__,i64 n) {
  return(({i64 is_even = (i64)(((i64*)__env__)[0]);
  ((n == 0) ? 0 : (({closure_t* __clo__ = (closure_t*)is_even;
  i64 __f__ = (i64)(__clo__->func_pointer);
  i64 __env__ = (i64)(__clo__->env);
  ((i64(*)(i64, i64))__f__)(__env__,(n - 1));
  })));}));
  }
  
  static i64 __is_even_lifted_3__(i64 __env__,i64 n) {
  return(({i64 is_odd = (i64)(((i64*)__env__)[0]);
  ((n == 0) ? 1 : (({closure_t* __clo__ = (closure_t*)is_odd;
  i64 __f__ = (i64)(__clo__->func_pointer);
  i64 __env__ = (i64)(__clo__->env);
  ((i64(*)(i64, i64))__f__)(__env__,(n - 1));
  })));}));
  }
  
