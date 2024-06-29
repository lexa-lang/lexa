#include <datastructure.h>
#include <defs.h>
#include <icfpAPI.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static i64 __solveLambdaMan_lifted_7__(i64, i64, i64);
static i64 body1(i64, i64);
static i64 body2(i64, i64);
static i64 __walk_lifted_6__(i64, i64, i64, i64, i64);
static i64 __findStart_lifted_5__(i64, i64, i64, i64, i64, i64, i64);
FAST_SWITCH_DECORATOR
i64 choice_choose(i64 *, i64, i64);
i64 tracer_record(i64 *, i64);
i64 tracer_isPinned(i64 *, i64, i64);
i64 tracer_pin(i64 *, i64, i64);
static i64 __allocateTrace_lifted_4__(i64);
static i64 __isPin_lifted_3__(i64, i64, i64, i64);
static i64 __allocatePinMap_lifted_2__(i64, i64, i64);
static i64 __allocatePinMapRow_lifted_1__(i64, i64, i64, i64, i64);
closure_t *solveLambdaMan;
closure_t *walk;
closure_t *findStart;
closure_t *allocateTrace;
closure_t *isPin;
closure_t *allocatePinMap;
closure_t *allocatePinMapRow;
enum Tracer { pin, isPinned, record };

enum Choice { choose };

static i64 __allocatePinMapRow_lifted_1__(i64 __env__, i64 i, i64 nrow,
                                          i64 ncol, i64 map) {
  return (((i == nrow) ? 0 : ({
    i64 rowData = (i64)(((i64)(arrayMakeInit((int64_t)ncol, (int64_t)0))));
    ({
      i64 _ = (i64)((
          (i64)(arraySet((array_t *)map, (int64_t)i, (int64_t)rowData))));
      ({
        i64 _ = (i64)(({
          closure_t *__clo__ = (closure_t *)allocatePinMapRow;
          i64 __f__ = (i64)(__clo__->func_pointer);
          i64 __env__ = (i64)(__clo__->env);
          ((i64(*)(i64, i64, i64, i64, i64))__f__)(__env__, (i + 1), nrow, ncol,
                                                   map);
        }));
        0;
      });
    });
  })));
}

static i64 __allocatePinMap_lifted_2__(i64 __env__, i64 nrow, i64 ncol) {
  return (({
    i64 map = (i64)(((i64)(arrayMake((int64_t)nrow))));
    ({
      i64 _ = (i64)(({
        closure_t *__clo__ = (closure_t *)allocatePinMapRow;
        i64 __f__ = (i64)(__clo__->func_pointer);
        i64 __env__ = (i64)(__clo__->env);
        ((i64(*)(i64, i64, i64, i64, i64))__f__)(__env__, 0, nrow, ncol, map);
      }));
      map;
    });
  }));
}

static i64 __isPin_lifted_3__(i64 __env__, i64 row, i64 col, i64 pinMap) {
  return (({
    i64 rowData = (i64)(((i64)(arrayAt((array_t *)pinMap, (int64_t)row))));
    (((i64)(arrayAt((array_t *)rowData, (int64_t)col))));
  }));
}

static i64 __allocateTrace_lifted_4__(i64 __env__) {
  return ((((i64)(arrayMake((int64_t)0)))));
}

i64 tracer_pin(i64 *env, i64 row, i64 col) {
  return (({
    i64 pinMap = (i64)(((i64 *)env)[4]);
    ({
      i64 row = (i64)(((i64)(arrayAt((array_t *)pinMap, (int64_t)row))));
      ({
        i64 _ =
            (i64)(((i64)(arraySet((array_t *)row, (int64_t)col, (int64_t)1))));
        0;
      });
    });
  }));
}

i64 tracer_isPinned(i64 *env, i64 row, i64 col) {
  return (({
    i64 pinMap = (i64)(((i64 *)env)[4]);
    ({
      i64 rowData = (i64)(((i64)(arrayAt((array_t *)pinMap, (int64_t)row))));
      (((i64)(arrayAt((array_t *)rowData, (int64_t)col))));
    });
  }));
}

i64 tracer_record(i64 *env, i64 action) {
  return (({
    i64 trace = (i64)(((i64 *)env)[5]);
    ({
      i64 _ = (i64)(((i64)(arrayPush((array_t *)trace, (int64_t)action))));
      0;
    });
  }));
}

FAST_SWITCH_DECORATOR
i64 choice_choose(i64 *env, i64 pair, i64 k) {
  return (({
    i64 row = (i64)(((i64)(pairFst((int64_t)pair))));
    ({
      i64 col = (i64)(((i64)(pairSnd((int64_t)pair))));
      ({
        printf("Choose starting at: (%d, %d)\n", (int)row, (int)col);
        i64 nrow = (i64)(((i64 *)env)[2]);
        ({
          i64 ncol = (i64)(((i64 *)env)[3]);
          ({
            i64 tracer_stub = (i64)(((i64 *)env)[4]);
            ({
              i64 newrow = (i64)(row - 1);
              ({
                i64 newcol = (i64)col;
                ({
                  i64 _ =
                      (i64)((((i64)(boolAnd(
                                (int64_t)(newrow > -1),
                                (int64_t)((RAISE(tracer_stub, isPinned,
                                                 (newrow, newcol))) == 0)))))
                                ? ({
                                    i64 _ =
                                        (i64)(RAISE(tracer_stub, record, (85)));
                                    ({
                                        printf("Choose 85\n");
                                      i64 _ = (i64)(THROW(k, 85));
                                      ({
                                        i64 _ = (i64)(RAISE(tracer_stub, record,
                                                            (68)));
                                        0;
                                      });
                                    });
                                  })
                                : 0);
                  ({
                    i64 newrow = (i64)row;
                    ({
                      i64 newcol = (i64)(col + 1);
                      ({
                        i64 _ =
                            (i64)((((i64)(boolAnd(
                                      (int64_t)(newcol < ncol),
                                      (int64_t)((RAISE(tracer_stub, isPinned,
                                                       (newrow, newcol))) ==
                                                0)))))
                                      ? ({
                                          i64 _ = (i64)(RAISE(tracer_stub,
                                                              record, (82)));
                                          ({
                                            printf("Choose 82\n");
                                            i64 _ = (i64)(THROW(k, 82));
                                            ({
                                              i64 _ = (i64)(RAISE(
                                                  tracer_stub, record, (76)));
                                              0;
                                            });
                                          });
                                        })
                                      : 0);
                        ({
                          i64 newrow = (i64)(row + 1);
                          ({
                            i64 newcol = (i64)col;
                            ({
                              i64 _ =
                                  (i64)((((i64)(boolAnd(
                                            (int64_t)(newrow < nrow),
                                            (int64_t)((RAISE(
                                                          tracer_stub, isPinned,
                                                          (newrow, newcol))) ==
                                                      0)))))
                                            ? ({
                                                i64 _ = (i64)(RAISE(
                                                    tracer_stub, record, (68)));
                                                ({
                                                    printf("Choose 68\n");
                                                  i64 _ = (i64)(THROW(k, 68));
                                                  ({
                                                    i64 _ = (i64)(RAISE(
                                                        tracer_stub, record,
                                                        (85)));
                                                    0;
                                                  });
                                                });
                                              })
                                            : 0);
                              ({
                                i64 newrow = (i64)row;
                                ({
                                  i64 newcol = (i64)(col - 1);
                                  ({
                                    i64 _ =
                                        (i64)((((i64)(boolAnd(
                                                  (int64_t)(newcol > -1),
                                                  (int64_t)((RAISE(tracer_stub,
                                                                   isPinned,
                                                                   (newrow,
                                                                    newcol))) ==
                                                            0)))))
                                                  ? ({
                                                      i64 _ = (i64)(RAISE(
                                                          tracer_stub, record,
                                                          (76)));
                                                      ({
                                                            printf("Choose 76\n");
                                                        i64 _ =
                                                            (i64)(THROW(k, 76));
                                                        ({
                                                          i64 _ = (i64)(RAISE(
                                                              tracer_stub,
                                                              record, (82)));
                                                          0;
                                                        });
                                                      });
                                                    })
                                                  : 0);
                                    0;
                                  });
                                });
                              });
                            });
                          });
                        });
                      });
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

static i64 __findStart_lifted_5__(i64 __env__, i64 i, i64 j, i64 nrow, i64 ncol,
                                  i64 outx, i64 outy) {
  return ((
      (i == nrow)
          ? (((i64)(done())))
          : ((j == ncol)
                 ? (({
                     closure_t *__clo__ = (closure_t *)findStart;
                     i64 __f__ = (i64)(__clo__->func_pointer);
                     i64 __env__ = (i64)(__clo__->env);
                     ((i64(*)(i64, i64, i64, i64, i64, i64, i64))__f__)(
                         __env__, (i + 1), 0, nrow, ncol, outx, outy);
                   }))
                 : (((((i64)(lambdaManGetField((int64_t)i, (int64_t)j)))) == 76)
                        ? ({
                            i64 _ = (i64)(((i64 *)outx)[0] = i);
                            ({
                              i64 _ = (i64)(((i64 *)outy)[0] = j);
                              0;
                            });
                          })
                        : (({
                            closure_t *__clo__ = (closure_t *)findStart;
                            i64 __f__ = (i64)(__clo__->func_pointer);
                            i64 __env__ = (i64)(__clo__->env);
                            ((i64(*)(i64, i64, i64, i64, i64, i64, i64))__f__)(
                                __env__, i, (j + 1), nrow, ncol, outx, outy);
                          }))))));
}

static i64 __walk_lifted_6__(i64 __env__, i64 row, i64 col, i64 tracer_stub,
                             i64 choice_stub) {
  printf("walk at %d %d\n", (int)row, (int)col);
  return (({
    i64 _ = (i64)(RAISE(tracer_stub, pin, (row, col)));
    ({
      i64 pair = (i64)(((i64)(pairMake((int32_t)row, (int32_t)col))));
      ({
        i64 step = (i64)(RAISE(choice_stub, choose, (pair)));
        printf("step %d\n", (int)step);
        ((step == 85)
             ? (({
                 closure_t *__clo__ = (closure_t *)walk;
                 i64 __f__ = (i64)(__clo__->func_pointer);
                 i64 __env__ = (i64)(__clo__->env);
                 ((i64(*)(i64, i64, i64, i64, i64))__f__)(
                     __env__, (row - 1), col, tracer_stub, choice_stub);
               }))
             : ((step == 82)
                    ? (({
                        closure_t *__clo__ = (closure_t *)walk;
                        i64 __f__ = (i64)(__clo__->func_pointer);
                        i64 __env__ = (i64)(__clo__->env);
                        ((i64(*)(i64, i64, i64, i64, i64))__f__)(
                            __env__, row, (col + 1), tracer_stub, choice_stub);
                      }))
                    : ((step == 68) ? (({
                        closure_t *__clo__ = (closure_t *)walk;
                        i64 __f__ = (i64)(__clo__->func_pointer);
                        i64 __env__ = (i64)(__clo__->env);
                        ((i64(*)(i64, i64, i64, i64, i64))__f__)(
                            __env__, (row + 1), col, tracer_stub, choice_stub);
                      }))
                                    : ((step == 76) ? (({
                                        closure_t *__clo__ = (closure_t *)walk;
                                        i64 __f__ =
                                            (i64)(__clo__->func_pointer);
                                        i64 __env__ = (i64)(__clo__->env);
                                        ((i64(*)(i64, i64, i64, i64, i64))
                                             __f__)(__env__, row, (col - 1),
                                                    tracer_stub, choice_stub);
                                      }))
                                                    : 0))));
      });
    });
  }));
}

static i64 body2(i64 env, i64 choice_stub) {
  return (({
    i64 startrow = (i64)(((i64 *)env)[0]);
    ({
      i64 startcol = (i64)(((i64 *)env)[1]);
      ({
        i64 tracer_stub = (i64)(((i64 *)env)[4]);
        (({
          closure_t *__clo__ = (closure_t *)walk;
          i64 __f__ = (i64)(__clo__->func_pointer);
          i64 __env__ = (i64)(__clo__->env);
          ((i64(*)(i64, i64, i64, i64, i64))__f__)(__env__, startrow, startcol,
                                                   tracer_stub, choice_stub);
        }));
      });
    });
  }));
}

static i64 body1(i64 env, i64 tracer_stub) {
  return (({
    i64 startrow = (i64)(((i64 *)env)[0]);
    ({
      i64 startcol = (i64)(((i64 *)env)[1]);
      ({
        i64 nrow = (i64)(((i64 *)env)[2]);
        ({
          i64 ncol = (i64)(((i64 *)env)[3]);
          (HANDLE(body2, ({MULTISHOT, choice_choose}),
                  (startrow, startcol, nrow, ncol, tracer_stub)));
        });
      });
    });
  }));
}

static i64 __solveLambdaMan_lifted_7__(i64 __env__, i64 nrow, i64 ncol) {
  return (({
    i64 startrow = (i64)(({
      i64 temp = (i64)malloc(1 * sizeof(i64));
      ((i64 *)temp)[0] = (i64)0;
      temp;
    }));
    ({
      i64 startcol = (i64)(({
        i64 temp = (i64)malloc(1 * sizeof(i64));
        ((i64 *)temp)[0] = (i64)0;
        temp;
      }));
      ({
        i64 _ = (i64)(({
          closure_t *__clo__ = (closure_t *)findStart;
          i64 __f__ = (i64)(__clo__->func_pointer);
          i64 __env__ = (i64)(__clo__->env);
          ((i64(*)(i64, i64, i64, i64, i64, i64, i64))__f__)(
              __env__, 0, 0, nrow, ncol, startrow, startcol);
        }));
        ({
          i64 _ = (i64)(((i64)(printInt((int64_t)(((i64 *)startrow)[0])))));
          ({
            i64 _ = (i64)(((i64)(printInt((int64_t)(((i64 *)startcol)[0])))));
            ({
              i64 pinMap = (i64)(({
                closure_t *__clo__ = (closure_t *)allocatePinMap;
                i64 __f__ = (i64)(__clo__->func_pointer);
                i64 __env__ = (i64)(__clo__->env);
                ((i64(*)(i64, i64, i64))__f__)(__env__, nrow, ncol);
              }));
              ({
                i64 trace = (i64)(({
                  closure_t *__clo__ = (closure_t *)allocateTrace;
                  i64 __f__ = (i64)(__clo__->func_pointer);
                  i64 __env__ = (i64)(__clo__->env);
                  ((i64(*)(i64))__f__)(__env__);
                }));
                ({
                  i64 startrow0 = (i64)(((i64 *)startrow)[0]);
                  ({
                    i64 startcol0 = (i64)(((i64 *)startcol)[0]);
                    ({
                      i64 _ = (i64)(HANDLE(
                          body1,
                          ({TAIL, tracer_pin}, {TAIL, tracer_isPinned},
                           {TAIL, tracer_record}),
                          (startrow0, startcol0, nrow, ncol, pinMap, trace)));
                      0;
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

int main(int argc, char *argv[]) {
  init_stack_pool();
  solveLambdaMan = malloc(sizeof(closure_t));
  solveLambdaMan->func_pointer = (i64)__solveLambdaMan_lifted_7__;
  solveLambdaMan->env = (i64)NULL;
  walk = malloc(sizeof(closure_t));
  walk->func_pointer = (i64)__walk_lifted_6__;
  walk->env = (i64)NULL;
  findStart = malloc(sizeof(closure_t));
  findStart->func_pointer = (i64)__findStart_lifted_5__;
  findStart->env = (i64)NULL;
  allocateTrace = malloc(sizeof(closure_t));
  allocateTrace->func_pointer = (i64)__allocateTrace_lifted_4__;
  allocateTrace->env = (i64)NULL;
  isPin = malloc(sizeof(closure_t));
  isPin->func_pointer = (i64)__isPin_lifted_3__;
  isPin->env = (i64)NULL;
  allocatePinMap = malloc(sizeof(closure_t));
  allocatePinMap->func_pointer = (i64)__allocatePinMap_lifted_2__;
  allocatePinMap->env = (i64)NULL;
  allocatePinMapRow = malloc(sizeof(closure_t));
  allocatePinMapRow->func_pointer = (i64)__allocatePinMapRow_lifted_1__;
  allocatePinMapRow->env = (i64)NULL;

  i64 __res__ = ({
    i64 _ = (i64)(((i64)(lambdaManInit())));
    ({
      i64 ncol = (i64)(((i64)(lambdaManGetWidth())));
      ({
        i64 nrow = (i64)(((i64)(lambdaManGetHeight())));
        ({
          i64 _ = (i64)(({
            closure_t *__clo__ = (closure_t *)solveLambdaMan;
            i64 __f__ = (i64)(__clo__->func_pointer);
            i64 __env__ = (i64)(__clo__->env);
            ((i64(*)(i64, i64, i64))__f__)(__env__, nrow, ncol);
          }));
          0;
        });
      });
    });
  });
  destroy_stack_pool();
  return ((int)__res__);
}
