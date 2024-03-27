#include <defs.h>
#include <datastructure.h>

i64 enumerate(i64 i) {
  return (i < 0) ? ({
    (i64)listEnd();
   }) : ({
    (i64)listNode(i, (node_t*)enumerate(i - 1));
   });
}

FAST_SWITCH_DECORATOR
i64 done(i64 env, i64 r) {
  return ({
    r;
  });
}

static i64 product(i64 abort_stub, i64 xs) {
  return (listIsEmpty((node_t*)xs)) ? ({
    0;
  }) : ({
    i64 y = (i64)listHead((node_t*)xs);
    i64 ys = (i64)listTail((node_t*)xs);
    (y == 0) ? ({
      RAISE(abort_stub, 0, (0));
    }): ({
      y * product(abort_stub, ys);
    });
  });
}

FAST_SWITCH_DECORATOR
static i64 body(i64 abort_stub) {
  return ({
    product(abort_stub, ((meta_t*)abort_stub)->env[0]);
  });
}

static i64 runProduct(i64 xs) {
  return ({
    HANDLE(body, ({ABORT, done}), (xs));
  });
}

static i64 loop(i64 xs, i64 i, i64 a) {
  (i == 0) ? ({
    return a;
  }) : ({
    // TODO: how can we remove the musttail attribute?
    // Invest if we can get ride of taking alloca address in runProduct. Such behavior prevents tail call optimization.
    __attribute__((musttail))
    return loop(xs, i - 1, a + runProduct(xs));
  });
}

static i64 run(i64 n) {
  return ({
    i64 xs = enumerate(1000);
    loop(xs, n, 0);
  });
}

int main(int argc, char *argv[]) {
  printInt(run(readInt()));
  return 0;
}