  $ lexa ../lexa_snippets/tail_fact.lx -o main --output-c &> /dev/null
  $ cat ../lexa_snippets/tail_fact.c
  #include <datastructure.h>
  #include <stacktrek.h>
  #include <stdbool.h>
  #include <stdint.h>
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  
  static i64 __fact_tail_lifted_3__(i64, i64, i64);
  static i64 __fact_nontail_lifted_2__(i64, i64);
  static closure_t *fact_tail;
  static closure_t *fact_nontail;
  int main(int argc, char *argv[]) {
    init_stack_pool();
    fact_tail = xmalloc(sizeof(closure_t));
    fact_tail->func_pointer = (i64)__fact_tail_lifted_3__;
    fact_tail->env = (i64)NULL;
    fact_nontail = xmalloc(sizeof(closure_t));
    fact_nontail->func_pointer = (i64)__fact_nontail_lifted_2__;
    fact_nontail->env = (i64)NULL;
  
    i64 __res__ = ({
      i64 x = (i64)((i64)(readInt()));
      ({
        i64 r1 =
            (i64)(((i64(*)(i64, i64))__fact_nontail_lifted_2__)((i64)0, (i64)x));
        ({
          i64 r2 = (i64)(((i64(*)(i64, i64, i64))__fact_tail_lifted_3__)(
              (i64)0, (i64)x, (i64)1));
          ({
            i64 _ = (i64)((i64)(printInt((int64_t)r1)));
            ({
              i64 _ = (i64)((i64)(printInt((int64_t)r2)));
              0;
            });
          });
        });
      });
    });
    destroy_stack_pool();
    return ((int)__res__);
  }
  static i64 __fact_nontail_lifted_2__(i64 __env__, i64 x) {
    return (((x < 2) ? 1
                     : (x * (((i64(*)(i64, i64))__fact_nontail_lifted_2__)(
                                (i64)0, (i64)(x - 1))))));
  }
  
  static i64 __fact_tail_lifted_3__(i64 __env__, i64 x, i64 acc) {
    return (((x < 2) ? acc : (({
      __attribute__((musttail)) return (
          (i64(*)(i64, i64, i64))__fact_tail_lifted_3__)((i64)0, (i64)(x - 1),
                                                         (i64)(x * acc));
      0;
    }))));
  }
  
