  $ lexa ../../benchmarks/lexa/parsing_dollars/main.lx -o main --output-c &> /dev/null
  $ cat ../../benchmarks/lexa/parsing_dollars/main.c
  #include <datastructure.h>
  #include <stacktrek.h>
  #include <stdbool.h>
  #include <stdint.h>
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  
  static i64 __handle_body_lifted_14__(i64, i64);
  i64 __emit_stub_lifted_15___emit(i64 *, i64);
  static i64 __handle_body_lifted_16__(i64, i64);
  i64 __stop_stub_lifted_17___stop(i64 *, i64);
  static i64 __handle_body_lifted_18__(i64, i64);
  i64 __read_stub_lifted_19___read(i64 *);
  static i64 __run_lifted_12__(i64, i64);
  static i64 __catch_action_lifted_11__(i64, i64, i64, i64);
  static i64 __sum_action_lifted_10__(i64, i64, i64);
  static i64 __feed_action_lifted_9__(i64, i64, i64, i64);
  static i64 __parse_lifted_8__(i64, i64, i64, i64, i64);
  static i64 __feed_lifted_7__(i64, i64, i64, i64, i64);
  static i64 __catch_lifted_6__(i64, i64, i64, i64);
  static i64 __sum_lifted_5__(i64, i64, i64);
  static i64 __is_dollar_lifted_4__(i64, i64);
  static i64 __dollar_lifted_3__(i64);
  static i64 __is_newline_lifted_2__(i64, i64);
  static i64 __newline_lifted_1__(i64);
  static closure_t *run;
  static closure_t *catch_action;
  static closure_t *sum_action;
  static closure_t *feed_action;
  static closure_t *parse;
  static closure_t *feed;
  static closure_t *catch;
  static closure_t *sum;
  static closure_t *is_dollar;
  static closure_t *dollar;
  static closure_t *is_newline;
  static closure_t *newline;
  enum Read { read };
  
  enum Emit { emit };
  
  enum Stop { stop };
  
  static i64 __newline_lifted_1__(i64 __env__) { return (10); }
  
  static i64 __is_newline_lifted_2__(i64 __env__, i64 c) { return ((c == 10)); }
  
  static i64 __dollar_lifted_3__(i64 __env__) { return (36); }
  
  static i64 __is_dollar_lifted_4__(i64 __env__, i64 c) { return ((c == 36)); }
  
  static i64 __sum_lifted_5__(i64 __env__, i64 action, i64 n) {
    return (({
      i64 s = (i64)(({
        i64 __field_0__ = (i64)0;
        i64 *__newref__ = xmalloc(1 * sizeof(i64));
        __newref__[0] = __field_0__;
        (i64) __newref__;
      }));
      ({
        (HANDLE(__handle_body_lifted_14__, ({TAIL, __emit_stub_lifted_15___emit}),
                ((i64)action, (i64)n, (i64)s)));
        (((i64 *)s)[0]);
      });
    }));
  }
  
  static i64 __catch_lifted_6__(i64 __env__, i64 action, i64 emit_stub, i64 n) {
    return ((HANDLE(__handle_body_lifted_16__,
                    ({ABORT, __stop_stub_lifted_17___stop}),
                    ((i64)action, (i64)emit_stub, (i64)n))));
  }
  
  static i64 __feed_lifted_7__(i64 __env__, i64 n, i64 action, i64 stop_stub,
                               i64 emit_stub) {
    return (({
      i64 i_ref = (i64)(({
        i64 __field_0__ = (i64)0;
        i64 *__newref__ = xmalloc(1 * sizeof(i64));
        __newref__[0] = __field_0__;
        (i64) __newref__;
      }));
      ({
        i64 j_ref = (i64)(({
          i64 __field_0__ = (i64)0;
          i64 *__newref__ = xmalloc(1 * sizeof(i64));
          __newref__[0] = __field_0__;
          (i64) __newref__;
        }));
        (HANDLE(__handle_body_lifted_18__, ({TAIL, __read_stub_lifted_19___read}),
                ((i64)action, (i64)dollar, (i64)emit_stub, (i64)i_ref, (i64)j_ref,
                 (i64)n, (i64)newline, (i64)stop_stub)));
      });
    }));
  }
  
  static i64 __parse_lifted_8__(i64 __env__, i64 a, i64 read_stub, i64 emit_stub,
                                i64 stop_stub) {
    return (({
      i64 c = (i64)(RAISE(read_stub, read, ((i64)0)));
      ((((i64(*)(i64, i64))__is_dollar_lifted_4__)((i64)0, (i64)c))
           ? (({
               __attribute__((musttail)) return (
                   (i64(*)(i64, i64, i64, i64, i64))__parse_lifted_8__)(
                   (i64)0, (i64)(a + 1), (i64)read_stub, (i64)emit_stub,
                   (i64)stop_stub);
               0;
             }))
           : ((((i64(*)(i64, i64))__is_newline_lifted_2__)((i64)0, (i64)c))
                  ? ({
                      (RAISE(emit_stub, emit, ((i64)a)));
                      (({
                        __attribute__((musttail)) return (
                            (i64(*)(i64, i64, i64, i64, i64))__parse_lifted_8__)(
                            (i64)0, (i64)0, (i64)read_stub, (i64)emit_stub,
                            (i64)stop_stub);
                        0;
                      }));
                    })
                  : (RAISE(stop_stub, stop, ((i64)0)))));
    }));
  }
  
  static i64 __feed_action_lifted_9__(i64 __env__, i64 read_stub, i64 emit_stub,
                                      i64 stop_stub) {
    return ((((i64(*)(i64, i64, i64, i64, i64))__parse_lifted_8__)(
        (i64)0, (i64)0, (i64)read_stub, (i64)emit_stub, (i64)stop_stub)));
  }
  
  static i64 __sum_action_lifted_10__(i64 __env__, i64 emit_stub, i64 n) {
    return (({
      i64 catch_action_i64 = (i64)catch_action;
      (((i64(*)(i64, i64, i64, i64))__catch_lifted_6__)(
          (i64)0, (i64)catch_action_i64, (i64)emit_stub, (i64)n));
    }));
  }
  
  static i64 __catch_action_lifted_11__(i64 __env__, i64 stop_stub, i64 emit_stub,
                                        i64 n) {
    return (({
      i64 feed_action_i64 = (i64)feed_action;
      (((i64(*)(i64, i64, i64, i64, i64))__feed_lifted_7__)(
          (i64)0, (i64)n, (i64)feed_action_i64, (i64)stop_stub, (i64)emit_stub));
    }));
  }
  
  static i64 __run_lifted_12__(i64 __env__, i64 n) {
    return (({
      i64 sum_action_i64 = (i64)sum_action;
      (((i64(*)(i64, i64, i64))__sum_lifted_5__)((i64)0, (i64)sum_action_i64,
                                                 (i64)n));
    }));
  }
  
  int main(int argc, char *argv[]) {
    init_stack_pool();
    run = xmalloc(sizeof(closure_t));
    run->func_pointer = (i64)__run_lifted_12__;
    run->env = (i64)NULL;
    catch_action = xmalloc(sizeof(closure_t));
    catch_action->func_pointer = (i64)__catch_action_lifted_11__;
    catch_action->env = (i64)NULL;
    sum_action = xmalloc(sizeof(closure_t));
    sum_action->func_pointer = (i64)__sum_action_lifted_10__;
    sum_action->env = (i64)NULL;
    feed_action = xmalloc(sizeof(closure_t));
    feed_action->func_pointer = (i64)__feed_action_lifted_9__;
    feed_action->env = (i64)NULL;
    parse = xmalloc(sizeof(closure_t));
    parse->func_pointer = (i64)__parse_lifted_8__;
    parse->env = (i64)NULL;
    feed = xmalloc(sizeof(closure_t));
    feed->func_pointer = (i64)__feed_lifted_7__;
    feed->env = (i64)NULL;
    catch = xmalloc(sizeof(closure_t));
    catch->func_pointer = (i64)__catch_lifted_6__;
    catch->env = (i64)NULL;
    sum = xmalloc(sizeof(closure_t));
    sum->func_pointer = (i64)__sum_lifted_5__;
    sum->env = (i64)NULL;
    is_dollar = xmalloc(sizeof(closure_t));
    is_dollar->func_pointer = (i64)__is_dollar_lifted_4__;
    is_dollar->env = (i64)NULL;
    dollar = xmalloc(sizeof(closure_t));
    dollar->func_pointer = (i64)__dollar_lifted_3__;
    dollar->env = (i64)NULL;
    is_newline = xmalloc(sizeof(closure_t));
    is_newline->func_pointer = (i64)__is_newline_lifted_2__;
    is_newline->env = (i64)NULL;
    newline = xmalloc(sizeof(closure_t));
    newline->func_pointer = (i64)__newline_lifted_1__;
    newline->env = (i64)NULL;
  
    i64 __res__ = ({
      i64 n = (i64)((i64)(readInt()));
      ({
        i64 run_result =
            (i64)(((i64(*)(i64, i64))__run_lifted_12__)((i64)0, (i64)n));
        ({
          ((i64)(printInt((int64_t)run_result)));
          0;
        });
      });
    });
    destroy_stack_pool();
    return ((int)__res__);
  }
  i64 __read_stub_lifted_19___read(i64 *__env__) {
    return (({
      i64 action = (i64)(((i64 *)__env__)[0]);
      ({
        i64 dollar = (i64)(((i64 *)__env__)[1]);
        ({
          i64 emit_stub = (i64)(((i64 *)__env__)[2]);
          ({
            i64 i_ref = (i64)(((i64 *)__env__)[3]);
            ({
              i64 j_ref = (i64)(((i64 *)__env__)[4]);
              ({
                i64 n = (i64)(((i64 *)__env__)[5]);
                ({
                  i64 newline = (i64)(((i64 *)__env__)[6]);
                  ({
                    i64 stop_stub = (i64)(((i64 *)__env__)[7]);
                    ({
                      i64 i = (i64)(((i64 *)i_ref)[0]);
                      ({
                        i64 j = (i64)(((i64 *)j_ref)[0]);
                        ((i > n)
                             ? (RAISE(stop_stub, stop, ((i64)0)))
                             : ((j == 0) ? ({
                                 (((i64 *)i_ref)[0] = (i + 1));
                                 ({
                                   (((i64 *)j_ref)[0] = (i + 1));
                                   (((i64(*)(i64))__newline_lifted_1__)((i64)0));
                                 });
                               })
                                         : ({
                                             (((i64 *)j_ref)[0] = (j - 1));
                                             (((i64(*)(i64))__dollar_lifted_3__)(
                                                 (i64)0));
                                           })));
                      });
                    });
                  });
                });
              });
            });
          });
        });
      });
    }));
  }
  
  static i64 __handle_body_lifted_18__(i64 __env__, i64 read_stub) {
    return (({
      i64 action = (i64)(((i64 *)__env__)[0]);
      ({
        i64 dollar = (i64)(((i64 *)__env__)[1]);
        ({
          i64 emit_stub = (i64)(((i64 *)__env__)[2]);
          ({
            i64 i_ref = (i64)(((i64 *)__env__)[3]);
            ({
              i64 j_ref = (i64)(((i64 *)__env__)[4]);
              ({
                i64 n = (i64)(((i64 *)__env__)[5]);
                ({
                  i64 newline = (i64)(((i64 *)__env__)[6]);
                  ({
                    i64 stop_stub = (i64)(((i64 *)__env__)[7]);
                    (({
                      closure_t *__clo__ = (closure_t *)action;
                      i64 __f__ = (i64)(__clo__->func_pointer);
                      i64 __env__ = (i64)(__clo__->env);
                      ((i64(*)(i64, i64, i64, i64))__f__)(__env__, read_stub,
                                                          emit_stub, stop_stub);
                    }));
                  });
                });
              });
            });
          });
        });
      });
    }));
  }
  
  i64 __stop_stub_lifted_17___stop(i64 *__env__, i64 _) {
    return (({
      i64 action = (i64)(((i64 *)__env__)[0]);
      ({
        i64 emit_stub = (i64)(((i64 *)__env__)[1]);
        ({
          i64 n = (i64)(((i64 *)__env__)[2]);
          0;
        });
      });
    }));
  }
  
  static i64 __handle_body_lifted_16__(i64 __env__, i64 stop_stub) {
    return (({
      i64 action = (i64)(((i64 *)__env__)[0]);
      ({
        i64 emit_stub = (i64)(((i64 *)__env__)[1]);
        ({
          i64 n = (i64)(((i64 *)__env__)[2]);
          (({
            closure_t *__clo__ = (closure_t *)action;
            i64 __f__ = (i64)(__clo__->func_pointer);
            i64 __env__ = (i64)(__clo__->env);
            ((i64(*)(i64, i64, i64, i64))__f__)(__env__, stop_stub, emit_stub, n);
          }));
        });
      });
    }));
  }
  
  i64 __emit_stub_lifted_15___emit(i64 *__env__, i64 e) {
    return (({
      i64 action = (i64)(((i64 *)__env__)[0]);
      ({
        i64 n = (i64)(((i64 *)__env__)[1]);
        ({
          i64 s = (i64)(((i64 *)__env__)[2]);
          (((i64 *)s)[0] = ((((i64 *)s)[0]) + e));
        });
      });
    }));
  }
  
  static i64 __handle_body_lifted_14__(i64 __env__, i64 emit_stub) {
    return (({
      i64 action = (i64)(((i64 *)__env__)[0]);
      ({
        i64 n = (i64)(((i64 *)__env__)[1]);
        ({
          i64 s = (i64)(((i64 *)__env__)[2]);
          (({
            closure_t *__clo__ = (closure_t *)action;
            i64 __f__ = (i64)(__clo__->func_pointer);
            i64 __env__ = (i64)(__clo__->env);
            ((i64(*)(i64, i64, i64))__f__)(__env__, emit_stub, n);
          }));
        });
      });
    }));
  }
  
