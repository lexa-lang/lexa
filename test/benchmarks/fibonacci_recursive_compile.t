  $ lexa ../../benchmarks/lexa/fibonacci_recursive/main.lx -o main --output-c &> /dev/null
  $ cat ../../benchmarks/lexa/fibonacci_recursive/main.c
  #include <datastructure.h>
  #include <stacktrek.h>
  #include <stdbool.h>
  #include <stdint.h>
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  
  static i64 __fib_lifted_1__(i64, i64);
  static closure_t *fib;
  static i64 __fib_lifted_1__(i64 __env__, i64 n) {
    return (((n == 0) ? 0
                      : ((n == 1) ? 1
                                  : ((((i64(*)(i64, i64))__fib_lifted_1__)(
                                         (i64)0, (i64)(n - 1))) +
                                     (((i64(*)(i64, i64))__fib_lifted_1__)(
                                         (i64)0, (i64)(n - 2)))))));
  }
  
  int main(int argc, char *argv[]) {
    init_stack_pool();
    fib = xmalloc(sizeof(closure_t));
    fib->func_pointer = (i64)__fib_lifted_1__;
    fib->env = (i64)NULL;
  
    i64 __res__ = ({
      i64 arg = (i64)((i64)(readInt()));
      ({
        i64 res = (i64)(((i64(*)(i64, i64))__fib_lifted_1__)((i64)0, (i64)arg));
        ({
          ((i64)(printInt((int64_t)res)));
          0;
        });
      });
    });
    destroy_stack_pool();
    return ((int)__res__);
  }
