#include <datastructure.h>
#include <defs.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static i64 __loop_lifted_6__(i64, i64);
static i64 __fun_lifted_7__(i64, i64);
static i64 __fun_lifted_8__(i64, i64);
static i64 __fun_lifted_9__(i64);
static i64 __handle_body_lifted_10__(i64, i64);
FAST_SWITCH_DECORATOR
i64 __yield_stub_lifted_11___yield(i64 *, i64, i64);
static i64 __fun_lifted_12__(i64, i64);
static i64 __run_lifted_4__(i64, i64);
static i64 __explore_lifted_3__(i64, i64, i64, i64, i64);
static i64 __operator_lifted_2__(i64, i64, i64);
static i64 __make_lifted_1__(i64, i64);
static closure_t *run;
static closure_t *explore;
static closure_t *operator;
static closure_t *make;
enum Yield { yield };

static i64 __make_lifted_1__(i64 __env__, i64 n) {
  return (((n == 0) ? (((i64)(treeLeaf()))) : ({
    i64 t = (i64)(((i64(*)(i64, i64))__make_lifted_1__)(0, (n - 1)));
    (((i64)(treeNode((int64_t)n, (tree_t *)t, (tree_t *)t))));
  })));
}

static i64 __operator_lifted_2__(i64 __env__, i64 x, i64 y) {
  return (((((i64)(mathAbs((int64_t)((x - (503 * y)) + 37))))) % 1009));
}

static i64 __explore_lifted_3__(i64 __env__, i64 t, i64 rev, i64 state,
                                i64 yield_stub) {
  return (({
    (RAISE(yield_stub, yield, ((i64)0)));
    ((((i64)(treeIsEmpty((tree_t *)t)))) ? (((i64 *)state)[0]) : ({
      (((i64 *)state)[0] = (((i64(*)(i64, i64, i64))__operator_lifted_2__)(
           0, (((i64 *)state)[0]), (((i64)(treeValue((tree_t *)t)))))));
      (rev ? (((((i64)(treeValue((tree_t *)t)))) +
               (((i64(*)(i64, i64, i64, i64, i64))__explore_lifted_3__)(
                   0, (((i64)(treeLeft((tree_t *)t)))), rev, state,
                   yield_stub))) +
              (((i64(*)(i64, i64, i64, i64, i64))__explore_lifted_3__)(
                  0, (((i64)(treeRight((tree_t *)t)))), rev, state,
                  yield_stub)))
           : (((((i64)(treeValue((tree_t *)t)))) +
               (((i64(*)(i64, i64, i64, i64, i64))__explore_lifted_3__)(
                   0, (((i64)(treeRight((tree_t *)t)))), rev, state,
                   yield_stub))) +
              (((i64(*)(i64, i64, i64, i64, i64))__explore_lifted_3__)(
                  0, (((i64)(treeLeft((tree_t *)t)))), rev, state,
                  yield_stub))));
    }));
  }));
}

static i64 __run_lifted_4__(i64 __env__, i64 n) {
  return (({
    i64 tree = (i64)(((i64(*)(i64, i64))__make_lifted_1__)(0, n));
    ({
      i64 state = (i64)(({
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
          i64 yield_f = (i64)(({
            closure_t *__c__ = malloc(sizeof(closure_t));
            __c__->func_pointer = (i64)__fun_lifted_12__;
            __c__->env = (i64)malloc(1 * sizeof(i64));
            ((i64 *)(__c__->env))[0] = storage;
            (i64) __c__;
          }));
          ({
            i64 search = (i64)(({
              closure_t *__c__ = malloc(sizeof(closure_t));
              __c__->func_pointer = (i64)__fun_lifted_9__;
              __c__->env = (i64)malloc(4 * sizeof(i64));
              ((i64 *)(__c__->env))[0] = (i64)explore;
              ((i64 *)(__c__->env))[1] = state;
              ((i64 *)(__c__->env))[2] = tree;
              ((i64 *)(__c__->env))[3] = yield_f;
              (i64) __c__;
            }));
            ({
              i64 loop = (i64)(({
                closure_t *__c__ = malloc(sizeof(closure_t));
                __c__->func_pointer = (i64)__loop_lifted_6__;
                __c__->env = (i64)malloc(2 * sizeof(i64));
                ((i64 *)(__c__->env))[0] = search;
                ((i64 *)(__c__->env))[1] = state;
                (i64) __c__;
              }));
              (({
                closure_t *__clo__ = (closure_t *)loop;
                i64 __f__ = (i64)(__clo__->func_pointer);
                i64 __env__ = (i64)(__clo__->env);
                ((i64(*)(i64, i64))__f__)(__env__, 50);
              }));
            });
          });
        });
      });
    });
  }));
}

int main(int argc, char *argv[]) {
  init_stack_pool();
  run = malloc(sizeof(closure_t));
  run->func_pointer = (i64)__run_lifted_4__;
  run->env = (i64)NULL;
  explore = malloc(sizeof(closure_t));
  explore->func_pointer = (i64)__explore_lifted_3__;
  explore->env = (i64)NULL;
  operator= malloc(sizeof(closure_t));
  operator->func_pointer =(i64) __operator_lifted_2__;
  operator->env =(i64) NULL;
  make = malloc(sizeof(closure_t));
  make->func_pointer = (i64)__make_lifted_1__;
  make->env = (i64)NULL;

  i64 __res__ = ({
    i64 n = (i64)(((i64)(readInt())));
    ({
      i64 res = (i64)(((i64(*)(i64, i64))__run_lifted_4__)(0, n));
      ({
        (((i64)(printInt((int64_t)res))));
        0;
      });
    });
  });
  destroy_stack_pool();
  return ((int)__res__);
}
static i64 __fun_lifted_12__(i64 __env__, i64 action) {
  return (({
    i64 storage = (i64)(((i64 *)__env__)[0]);
    (HANDLE(__handle_body_lifted_10__,
            ({SINGLESHOT, __yield_stub_lifted_11___yield}),
            ((i64)action, (i64)storage)));
  }));
}

FAST_SWITCH_DECORATOR
i64 __yield_stub_lifted_11___yield(i64 *__env__, i64 _, i64 k) {
  return (({
    i64 action = (i64)(((i64 *)__env__)[0]);
    ({
      i64 storage = (i64)(((i64 *)__env__)[1]);
      ({
        i64 peer = (i64)(((i64 *)storage)[0]);
        ({
          (((i64 *)storage)[0] = k);
          ((peer != 0) ? (FINAL_THROW(peer, 0)) : 0);
        });
      });
    });
  }));
}

static i64 __handle_body_lifted_10__(i64 __env__, i64 yield_stub) {
  return (({
    i64 action = (i64)(((i64 *)__env__)[0]);
    ({
      i64 storage = (i64)(((i64 *)__env__)[1]);
      (({
        closure_t *__clo__ = (closure_t *)action;
        i64 __f__ = (i64)(__clo__->func_pointer);
        i64 __env__ = (i64)(__clo__->env);
        ((i64(*)(i64, i64))__f__)(__env__, yield_stub);
      }));
    });
  }));
}

static i64 __fun_lifted_9__(i64 __env__) {
  return (({
    i64 explore = (i64)(((i64 *)__env__)[0]);
    ({
      i64 state = (i64)(((i64 *)__env__)[1]);
      ({
        i64 tree = (i64)(((i64 *)__env__)[2]);
        ({
          i64 yield_f = (i64)(((i64 *)__env__)[3]);
          ({
            (({
              closure_t *__clo__ = (closure_t *)yield_f;
              i64 __f__ = (i64)(__clo__->func_pointer);
              i64 __env__ = (i64)(__clo__->env);
              ((i64(*)(i64, i64))__f__)(
                  __env__, (({
                    closure_t *__c__ = malloc(sizeof(closure_t));
                    __c__->func_pointer = (i64)__fun_lifted_8__;
                    __c__->env = (i64)malloc(3 * sizeof(i64));
                    ((i64 *)(__c__->env))[0] = explore;
                    ((i64 *)(__c__->env))[1] = state;
                    ((i64 *)(__c__->env))[2] = tree;
                    (i64) __c__;
                  })));
            }));
            (({
              closure_t *__clo__ = (closure_t *)yield_f;
              i64 __f__ = (i64)(__clo__->func_pointer);
              i64 __env__ = (i64)(__clo__->env);
              ((i64(*)(i64, i64))__f__)(
                  __env__, (({
                    closure_t *__c__ = malloc(sizeof(closure_t));
                    __c__->func_pointer = (i64)__fun_lifted_7__;
                    __c__->env = (i64)malloc(3 * sizeof(i64));
                    ((i64 *)(__c__->env))[0] = explore;
                    ((i64 *)(__c__->env))[1] = state;
                    ((i64 *)(__c__->env))[2] = tree;
                    (i64) __c__;
                  })));
            }));
          });
        });
      });
    });
  }));
}

static i64 __fun_lifted_8__(i64 __env__, i64 yield_stub) {
  return (({
    i64 explore = (i64)(((i64 *)__env__)[0]);
    ({
      i64 state = (i64)(((i64 *)__env__)[1]);
      ({
        i64 tree = (i64)(((i64 *)__env__)[2]);
        (((i64(*)(i64, i64, i64, i64, i64))__explore_lifted_3__)(
            0, tree, 1, state, yield_stub));
      });
    });
  }));
}

static i64 __fun_lifted_7__(i64 __env__, i64 yield_stub) {
  return (({
    i64 explore = (i64)(((i64 *)__env__)[0]);
    ({
      i64 state = (i64)(((i64 *)__env__)[1]);
      ({
        i64 tree = (i64)(((i64 *)__env__)[2]);
        (((i64(*)(i64, i64, i64, i64, i64))__explore_lifted_3__)(
            0, tree, 0, state, yield_stub));
      });
    });
  }));
}

static i64 __loop_lifted_6__(i64 __env__, i64 i) {
  return (({
    i64 search = (i64)(((i64 *)__env__)[0]);
    ({
      i64 state = (i64)(((i64 *)__env__)[1]);
      ({
        i64 loop = (i64)(({
          closure_t *__c__ = malloc(sizeof(closure_t));
          __c__->func_pointer = (i64)__loop_lifted_6__;
          __c__->env = (i64)malloc(2 * sizeof(i64));
          ((i64 *)(__c__->env))[0] = search;
          ((i64 *)(__c__->env))[1] = state;
          (i64) __c__;
        }));
        ((i == 0) ? (((i64 *)state)[0]) : ({
          (((i64 *)state)[0] = (({
             closure_t *__clo__ = (closure_t *)search;
             i64 __f__ = (i64)(__clo__->func_pointer);
             i64 __env__ = (i64)(__clo__->env);
             ((i64(*)(i64))__f__)(__env__);
           })));
          (({
            closure_t *__clo__ = (closure_t *)loop;
            i64 __f__ = (i64)(__clo__->func_pointer);
            i64 __env__ = (i64)(__clo__->env);
            ((i64(*)(i64, i64))__f__)(__env__, (i - 1));
          }));
        }));
      });
    });
  }));
}

