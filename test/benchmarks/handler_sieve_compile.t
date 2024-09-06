  $ lexa ../../benchmarks/lexa/handler_sieve/main.lx -o main.c
  $ cat main.c
  #include <stdint.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include <stdbool.h>
  #include <string.h>
  #include <stacktrek.h>
  #include <datastructure.h>
  
  static i64 __handle_body_lifted_4__(i64,i64);
   i64 __new_prime_stub_lifted_5___prime(i64*,i64);
  static i64 __handle_body_lifted_6__(i64,i64);
   i64 __prime_true_stub_lifted_7___prime(i64*,i64);
  static i64 __run_lifted_2__(i64,i64);
  static i64 __primes_lifted_1__(i64,i64,i64,i64,i64);
  static closure_t* run;
  static closure_t* primes;
  enum Prime {prime};
  
  static i64 __primes_lifted_1__(i64 __env__,i64 prime_stub,i64 i,i64 n,i64 a) {
  return(((i < n) ? ((RAISE(prime_stub, prime, ((i64)i))) ? (HANDLE(__handle_body_lifted_4__, ({TAIL, __new_prime_stub_lifted_5___prime}), ((i64)a, (i64)i, (i64)n, (i64)prime_stub, (i64)primes))) : (({__attribute__((musttail))
   return ((i64(*)(i64, i64, i64, i64, i64))__primes_lifted_1__)((i64)0, (i64)prime_stub, (i64)(i + 1), (i64)n, (i64)a); 0;}))) : a));
  }
  
  static i64 __run_lifted_2__(i64 __env__,i64 n) {
  return((HANDLE(__handle_body_lifted_6__, ({TAIL, __prime_true_stub_lifted_7___prime}), ((i64)n, (i64)primes))));
  }
  
  int main(int argc, char *argv[]) {
  init_stack_pool();
  run = xmalloc(sizeof(closure_t));
  run->func_pointer = (i64)__run_lifted_2__;
  run->env = (i64)NULL;
  primes = xmalloc(sizeof(closure_t));
  primes->func_pointer = (i64)__primes_lifted_1__;
  primes->env = (i64)NULL;
  
  i64 __res__ = ({i64 arg1 = (i64)(((i64)(readInt())));
  ({i64 arg2 = (i64)(((i64(*)(i64, i64))__run_lifted_2__)((i64)0, (i64)arg1));
  ({(((i64)(printInt((int64_t)arg2))));
  0;});});});
  destroy_stack_pool();
  return((int)__res__);}
   i64 __prime_true_stub_lifted_7___prime(i64* __env__,i64 e) {
  return(({i64 n = (i64)(((i64*)__env__)[0]);
  ({i64 primes = (i64)(((i64*)__env__)[1]);
  1;});}));
  }
  
  static i64 __handle_body_lifted_6__(i64 __env__,i64 prime_true_stub) {
  return(({i64 n = (i64)(((i64*)__env__)[0]);
  ({i64 primes = (i64)(((i64*)__env__)[1]);
  (((i64(*)(i64, i64, i64, i64, i64))__primes_lifted_1__)((i64)0, (i64)prime_true_stub, (i64)2, (i64)n, (i64)0));});}));
  }
  
   i64 __new_prime_stub_lifted_5___prime(i64* __env__,i64 e) {
  return(({i64 a = (i64)(((i64*)__env__)[0]);
  ({i64 i = (i64)(((i64*)__env__)[1]);
  ({i64 n = (i64)(((i64*)__env__)[2]);
  ({i64 prime_stub = (i64)(((i64*)__env__)[3]);
  ({i64 primes = (i64)(((i64*)__env__)[4]);
  (((e % i) == 0) ? 0 : (RAISE(prime_stub, prime, ((i64)e))));});});});});}));
  }
  
  static i64 __handle_body_lifted_4__(i64 __env__,i64 new_prime_stub) {
  return(({i64 a = (i64)(((i64*)__env__)[0]);
  ({i64 i = (i64)(((i64*)__env__)[1]);
  ({i64 n = (i64)(((i64*)__env__)[2]);
  ({i64 prime_stub = (i64)(((i64*)__env__)[3]);
  ({i64 primes = (i64)(((i64*)__env__)[4]);
  (((i64(*)(i64, i64, i64, i64, i64))__primes_lifted_1__)((i64)0, (i64)new_prime_stub, (i64)(i + 1), (i64)n, (i64)(a + i)));});});});});}));
  }
  
