  $ sstal ../lexi_snippets/closure_rec2.lexi -o main.c
  $ cat main.c
  #include <stdint.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include <stdbool.h>
  #include <string.h>
  #include <defs.h>
  #include <datastructure.h>
  
  static i64 __f_lifted_3__(i64);
  static i64 __g_lifted_4__(i64);
  static i64 __f_lifted_1__(i64);
  static closure_t* f;
  static i64 __f_lifted_1__(i64 __env__) {
  return(({i64 env_var1 = (i64)100;
  ({i64 env_var2 = (i64)200;
  ({closure_t* f = malloc(sizeof(closure_t));
  closure_t* g = malloc(sizeof(closure_t));
  
  f->env = (i64)malloc(1 * sizeof(i64));
  ((i64*)(f->env))[0] = (i64)g;
  f->func_pointer = (i64)__f_lifted_3__;
  
  g->env = (i64)malloc(2 * sizeof(i64));
  ((i64*)(g->env))[0] = (i64)env_var1;
  ((i64*)(g->env))[1] = (i64)env_var2;
  g->func_pointer = (i64)__g_lifted_4__;
  
  (({closure_t* __clo__ = (closure_t*)f;
  i64 __f__ = (i64)(__clo__->func_pointer);
  i64 __env__ = (i64)(__clo__->env);
  ((i64(*)(i64))__f__)(__env__);
  }));});});}));
  }
  
  int main(int argc, char *argv[]) {
  init_stack_pool();
  f = malloc(sizeof(closure_t));
  f->func_pointer = (i64)__f_lifted_1__;
  f->env = (i64)NULL;
  
  i64 __res__ = ({i64 _ = (i64)(((i64(*)(i64))__f_lifted_1__)(0));
  0;});
  destroy_stack_pool();
  return((int)__res__);}
  static i64 __g_lifted_4__(i64 __env__) {
  return(({i64 env_var1 = (i64)(((i64*)__env__)[0]);
  ({i64 env_var2 = (i64)(((i64*)__env__)[1]);
  ({i64 _ = (i64)(((i64)(printInt((int64_t)env_var1))));
  (((i64)(printInt((int64_t)env_var2))));});});}));
  }
  
  static i64 __f_lifted_3__(i64 __env__) {
  return(({i64 g = (i64)(((i64*)__env__)[0]);
  (({closure_t* __clo__ = (closure_t*)g;
  i64 __f__ = (i64)(__clo__->func_pointer);
  i64 __env__ = (i64)(__clo__->env);
  ((i64(*)(i64))__f__)(__env__);
  }));}));
  }
  