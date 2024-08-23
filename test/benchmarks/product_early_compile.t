  $ sstal ../../benchmarks/lexi/product_early/main.lx -o main.c
  $ cat main.c
  #include <stdint.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include <stdbool.h>
  #include <string.h>
  #include <defs.h>
  #include <datastructure.h>
  
  static i64 __handle_body_lifted_7__(i64,i64);
   i64 __abort_stub_lifted_8___done(i64*,i64);
  static i64 __run_lifted_5__(i64,i64);
  static i64 __loop_lifted_4__(i64,i64,i64,i64);
  static i64 __runProduct_lifted_3__(i64,i64);
  static i64 __enumerate_lifted_2__(i64,i64);
  static i64 __product_lifted_1__(i64,i64,i64);
  static closure_t* run;
  static closure_t* loop;
  static closure_t* runProduct;
  static closure_t* enumerate;
  static closure_t* product;
  enum Abort {done};
  
  static i64 __product_lifted_1__(i64 __env__,i64 xs,i64 abort_stub) {
  return(((((i64)(listIsEmpty((node_t*)xs)))) ? 0 : ({i64 y = (i64)(((i64)(listHead((node_t*)xs))));
  ({i64 ys = (i64)(((i64)(listTail((node_t*)xs))));
  ((y == 0) ? (RAISE(abort_stub, done, ((i64)0))) : (y * (((i64(*)(i64, i64, i64))__product_lifted_1__)(0,ys,abort_stub))));});})));
  }
  
  static i64 __enumerate_lifted_2__(i64 __env__,i64 i) {
  return(((i < 0) ? (((i64)(listEnd()))) : (((i64)(listNode((int64_t)i, (node_t*)(((i64(*)(i64, i64))__enumerate_lifted_2__)(0,(i - 1)))))))));
  }
  
  static i64 __runProduct_lifted_3__(i64 __env__,i64 xs) {
  return((HANDLE(__handle_body_lifted_7__, ({ABORT, __abort_stub_lifted_8___done}), ((i64)product, (i64)xs))));
  }
  
  static i64 __loop_lifted_4__(i64 __env__,i64 xs,i64 i,i64 a) {
  return(((i == 0) ? a : (({__attribute__((musttail))
   return ((i64(*)(i64, i64, i64, i64))__loop_lifted_4__)(0,xs,(i - 1),(a + (((i64(*)(i64, i64))__runProduct_lifted_3__)(0,xs)))); 0;}))));
  }
  
  static i64 __run_lifted_5__(i64 __env__,i64 n) {
  return((((i64(*)(i64, i64, i64, i64))__loop_lifted_4__)(0,(((i64(*)(i64, i64))__enumerate_lifted_2__)(0,1000)),n,0)));
  }
  
  int main(int argc, char *argv[]) {
  init_stack_pool();
  run = malloc(sizeof(closure_t));
  run->func_pointer = (i64)__run_lifted_5__;
  run->env = (i64)NULL;
  loop = malloc(sizeof(closure_t));
  loop->func_pointer = (i64)__loop_lifted_4__;
  loop->env = (i64)NULL;
  runProduct = malloc(sizeof(closure_t));
  runProduct->func_pointer = (i64)__runProduct_lifted_3__;
  runProduct->env = (i64)NULL;
  enumerate = malloc(sizeof(closure_t));
  enumerate->func_pointer = (i64)__enumerate_lifted_2__;
  enumerate->env = (i64)NULL;
  product = malloc(sizeof(closure_t));
  product->func_pointer = (i64)__product_lifted_1__;
  product->env = (i64)NULL;
  
  i64 __res__ = ({i64 arg1 = (i64)(((i64)(readInt())));
  ({i64 arg2 = (i64)(((i64(*)(i64, i64))__run_lifted_5__)(0,arg1));
  ({(((i64)(printInt((int64_t)arg2))));
  0;});});});
  destroy_stack_pool();
  return((int)__res__);}
   i64 __abort_stub_lifted_8___done(i64* __env__,i64 r) {
  return(({i64 product = (i64)(((i64*)__env__)[0]);
  ({i64 xs = (i64)(((i64*)__env__)[1]);
  r;});}));
  }
  
  static i64 __handle_body_lifted_7__(i64 __env__,i64 abort_stub) {
  return(({i64 product = (i64)(((i64*)__env__)[0]);
  ({i64 xs = (i64)(((i64*)__env__)[1]);
  (((i64(*)(i64, i64, i64))__product_lifted_1__)(0,xs,abort_stub));});}));
  }
  