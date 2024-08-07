#include <datastructure.h>
#include <defs.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static i64 __step_lifted_3__(i64, i64);
static i64 __handle_body_lifted_4__(i64, i64);
FAST_SWITCH_DECORATOR
i64 __thread_stub_lifted_5___yield(i64 *, i64, i64);
static i64 __fun_lifted_6__(i64);
static i64 __run_lifted_1__(i64, i64);
static closure_t *run;
enum Thread { yield };

static i64 __run_lifted_1__(i64 __env__, i64 n) {
  return (({
    i64 acc = (i64)(({
      i64 temp = (i64)malloc(1 * sizeof(i64));
      ((i64 *)temp)[0] = (i64)0;
      temp;
    }));
    ({
      i64 storage = (i64)(({
        i64 temp = (i64)malloc(1 * sizeof(i64));
        ((i64 *)temp)[0] = (i64)0;
        temp;
      }));
      ({
        i64 work = (i64)(({
          closure_t *__c__ = malloc(sizeof(closure_t));
          __c__->func_pointer = (i64)__fun_lifted_6__;
          __c__->env = (i64)malloc(3 * sizeof(i64));
          ((i64 *)(__c__->env))[0] = acc;
          ((i64 *)(__c__->env))[1] = n;
          ((i64 *)(__c__->env))[2] = storage;
          (i64) __c__;
        }));
        ({
          (({
            closure_t *__clo__ = (closure_t *)work;
            i64 __f__ = (i64)(__clo__->func_pointer);
            i64 __env__ = (i64)(__clo__->env);
            ((i64(*)(i64))__f__)(__env__);
          }));
          ({
            (({
              closure_t *__clo__ = (closure_t *)work;
              i64 __f__ = (i64)(__clo__->func_pointer);
              i64 __env__ = (i64)(__clo__->env);
              ((i64(*)(i64))__f__)(__env__);
            }));
            (((i64 *)acc)[0]);
          });
        });
      });
    });
  }));
}

int main(int argc, char *argv[]) {
  init_stack_pool();
  run = malloc(sizeof(closure_t));
  run->func_pointer = (i64)__run_lifted_1__;
  run->env = (i64)NULL;

  i64 __res__ = ({
    (((i64)(printInt((int64_t)(((i64(*)(i64, i64))__run_lifted_1__)(
        0, (((i64)(readInt())))))))));
    0;
  });
  destroy_stack_pool();
  return ((int)__res__);
}
static i64 __fun_lifted_6__(i64 __env__) {
  return (({
    i64 acc = (i64)(((i64 *)__env__)[0]);
    ({
      i64 n = (i64)(((i64 *)__env__)[1]);
      ({
        i64 storage = (i64)(((i64 *)__env__)[2]);
        (HANDLE(__handle_body_lifted_4__,
                ({SINGLESHOT, __thread_stub_lifted_5___yield}),
                ((i64)acc, (i64)n, (i64)storage)));
      });
    });
  }));
}

FAST_SWITCH_DECORATOR
i64 __thread_stub_lifted_5___yield(i64 *__env__, i64 _, i64 k) {
  return (({
    i64 acc = (i64)(((i64 *)__env__)[0]);
    ({
      i64 n = (i64)(((i64 *)__env__)[1]);
      ({
        i64 storage = (i64)(((i64 *)__env__)[2]);
        ({
          (((i64 *)acc)[0] = ((((i64 *)acc)[0]) + 1));
          ({
            i64 peer = (i64)(((i64 *)storage)[0]);
            ({
              (((i64 *)storage)[0] = k);
              ((peer == 0) ? 0 : (FINAL_THROW(peer, 0)));
            });
          });
        });
      });
    });
  }));
}

static i64 __handle_body_lifted_4__(i64 __env__, i64 thread_stub) {
  return (({
    i64 acc = (i64)(((i64 *)__env__)[0]);
    ({
      i64 n = (i64)(((i64 *)__env__)[1]);
      ({
        i64 storage = (i64)(((i64 *)__env__)[2]);
        ({
          i64 step = (i64)(({
            closure_t *__c__ = malloc(sizeof(closure_t));
            __c__->func_pointer = (i64)__step_lifted_3__;
            __c__->env = (i64)malloc(1 * sizeof(i64));
            ((i64 *)(__c__->env))[0] = thread_stub;
            (i64) __c__;
          }));
          (({
            closure_t *__clo__ = (closure_t *)step;
            i64 __f__ = (i64)(__clo__->func_pointer);
            i64 __env__ = (i64)(__clo__->env);
            i64 r = ((i64(*)(i64, i64))__f__)(__env__, n);
            free((i64*)__env__);
            free((closure_t *)step);
            r;
          }));
        });
      });
    });
  }));
}

static i64 __step_lifted_3__(i64 __env__, i64 i) {
  return (({
    i64 thread_stub = (i64)(((i64 *)__env__)[0]);
    ({
      i64 step = (i64)(({
        closure_t *__c__ = malloc(sizeof(closure_t));
        __c__->func_pointer = (i64)__step_lifted_3__;
        __c__->env = (i64)malloc(1 * sizeof(i64));
        ((i64 *)(__c__->env))[0] = thread_stub;
        (i64) __c__;
      }));
      ({
        (RAISE(thread_stub, yield, ((i64)0)));
        (({
          closure_t *__clo__ = (closure_t *)step;
          i64 __f__ = (i64)(__clo__->func_pointer);
          i64 __env__ = (i64)(__clo__->env);
          ((i64(*)(i64, i64))__f__)(__env__, (i - 1));
        }));
      });
    });
  }));
}
