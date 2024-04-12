  $ sstal ../lexi/interruptible_iterator/main.ir -o main.c
  $ cat main.c
  #include <stdint.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include <stdbool.h>
  #include <string.h>
  #include <defs.h>
  #include <datastructure.h>
  
  static i64 repeat(i64);
  static i64 step(i64,i64,i64);
  static i64 run(i64);
  static i64 listSum(i64,i64);
   i64 behead(i64*,i64);
  static i64 body_main_1(i64,i64);
   i64 yield(i64*,i64,i64,i64);
  static i64 body_main_2(i64,i64);
  static i64 loop(i64,i64,i64);
   i64 behead(i64*,i64);
  static i64 loop_body_2(i64,i64);
   i64 replace(i64*,i64);
  static i64 loop_body_1(i64,i64);
  
  
  
  static i64 loop_body_1(i64 env,i64 replace_stub) {
  return(({i64 it = (i64)(((i64*)env)[0]);
  ({i64 yield_stub = (i64)(((i64*)env)[1]);
  ({i64 behead_stub = (i64)(((i64*)env)[2]);
  ({i64 v = (i64)(((i64)(listHead((node_t*)it))));
  RAISE(yield_stub, 0, (v,behead_stub,replace_stub));});});});}));
  }
  
   i64 replace(i64* env,i64 x) {
  return(({i64 it = (i64)(((i64*)env)[0]);
  ((i64)(listSetHead((node_t*)it, (int64_t)x)));}));
  }
  
  static i64 loop_body_2(i64 env,i64 behead_stub) {
  return(({i64 it_tail = (i64)(((i64*)env)[0]);
  ({i64 yield_stub = (i64)(((i64*)env)[1]);
  ((i64(*)(i64, i64, i64))loop)(it_tail,yield_stub,behead_stub);});}));
  }
  
   i64 behead(i64* env,i64 _) {
  return(({i64 it = (i64)(((i64*)env)[0]);
  ({i64 beheaded = (i64)(((i64*)env)[2]);
  ((i64*)beheaded)[0] = 1;});}));
  }
  
  static i64 loop(i64 it,i64 yield_stub,i64 behead_stub) {
  return(({i64 _ = (i64)(HANDLE(loop_body_1, ({TAIL, replace}), (it, yield_stub, behead_stub)));
  ({i64 it_tail = (i64)(((i64)(listTail((node_t*)it))));
  ({i64 beheaded = (i64)(({i64 temp = (i64)malloc(1 * sizeof(i64));
  ((i64*)temp)[0] = (i64)0;
  temp;
  }));
  ({i64 cond = (i64)(((i64)(listIsEmpty((node_t*)it_tail))));
  ({i64 newtl = (i64)((cond) ? (((i64)(listEnd()))) : (HANDLE(loop_body_2, ({TAIL, behead}), (it_tail, yield_stub, beheaded))));
  ({i64 tobehead = (i64)(((i64*)beheaded)[0]);
  ({i64 _ = (i64)((tobehead) ? (({i64 tailtail = (i64)(((i64)(listTail((node_t*)newtl))));
  ((i64)(listSetTail((node_t*)it, (node_t*)tailtail)));})) : (0));
  it;});});});});});});}));
  }
  
  static i64 body_main_2(i64 env,i64 yield_stub) {
  return(({i64 behead_stub = (i64)(((i64*)env)[0]);
  ({i64 l = (i64)(((i64*)env)[1]);
  ((i64(*)(i64, i64, i64))loop)(l,yield_stub,behead_stub);});}));
  }
  
   i64 yield(i64* env,i64 x,i64 behead_stub,i64 replace_stub) {
  return(({i64 cond = (i64)(x < 0);
  (cond) ? (RAISE(behead_stub, 0, (0))) : (({i64 x2 = (i64)(x * 2);
  RAISE(replace_stub, 0, (x2));}));}));
  }
  
  static i64 body_main_1(i64 env,i64 behead_stub) {
  return(({i64 l = (i64)(((i64*)env)[0]);
  HANDLE(body_main_2, ({TAIL, yield}), (behead_stub, l));}));
  }
  
   i64 behead(i64* env,i64 _) {
  return(({i64 beheaded = (i64)(((i64*)env)[1]);
  ((i64*)beheaded)[0] = 1;}));
  }
  
  static i64 listSum(i64 l,i64 acc) {
  return(({i64 cond = (i64)(((i64)(listIsEmpty((node_t*)l))));
  (cond) ? (acc) : (({i64 head = (i64)(((i64)(listHead((node_t*)l))));
  ({i64 tail = (i64)(((i64)(listTail((node_t*)l))));
  ({i64 newacc = (i64)(acc + head);
  ((i64(*)(i64, i64))listSum)(tail,newacc);});});}));}));
  }
  
  static i64 run(i64 n) {
  return(({i64 minusn = (i64)(0 - n);
  ({i64 l = (i64)(((i64)(listRange((int64_t)minusn, (int64_t)n))));
  ({i64 beheaded = (i64)(({i64 temp = (i64)malloc(1 * sizeof(i64));
  ((i64*)temp)[0] = (i64)0;
  temp;
  }));
  ({i64 newtl = (i64)(HANDLE(body_main_1, ({TAIL, behead}), (l, beheaded)));
  ({i64 tobehead = (i64)(((i64*)beheaded)[0]);
  ({i64 res = (i64)((tobehead) ? (((i64)(listTail((node_t*)newtl)))) : (newtl));
  ((i64(*)(i64))listSum)(res);});});});});});}));
  }
  
  static i64 step(i64 i,i64 acc,i64 n_jobs) {
  return(({i64 cond = (i64)(i == 0);
  (cond) ? (acc) : (({i64 i_dec = (i64)(i - 1);
  ({i64 res = (i64)(((i64(*)(i64))run)(n_jobs));
  ({i64 acc2 = (i64)(acc + res);
  ((i64(*)(i64, i64, i64))step)(i_dec,acc2,n_jobs);});});}));}));
  }
  
  static i64 repeat(i64 n_jobs) {
  return(((i64(*)(i64, i64, i64))step)(1000,0,n_jobs));
  }
  
  int main(int argc, char *argv[]) {
  init_stack_pool();
  i64 __res__ = ({i64 arg1 = (i64)(((i64)(readInt())));
  ({i64 arg2 = (i64)(((i64(*)(i64))repeat)(arg1));
  ({i64 _ = (i64)(((i64)(printInt((int64_t)arg2))));
  0;});});});
  destroy_stack_pool();
  return((int)__res__);
  }
  
