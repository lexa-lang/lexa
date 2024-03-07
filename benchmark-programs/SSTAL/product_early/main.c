#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <defs.h>
#include <datastructure.h>

intptr_t ret_val;

intptr_t enumerate(intptr_t i) {
  return (i < 0) ? ({
    (intptr_t)listEnd();
   }) : ({
    (intptr_t)listNode(i, (node_t*)enumerate(i - 1));
   });
}

FAST_SWITCH_DECORATOR
intptr_t done(const intptr_t* const env, intptr_t r) {
  return ({
    r;
  });
}

static intptr_t product(meta_t *abort_stub, intptr_t xs) {
  return (listIsEmpty((node_t*)xs)) ? ({
    0;
  }) : ({
    intptr_t y = (intptr_t)listHead((node_t*)xs);
    intptr_t ys = (intptr_t)listTail((node_t*)xs);
    (y == 0) ? ({
      RAISE(abort_stub, 0, (0));
    }): ({
      y * product(abort_stub, ys);
    });
  });
}

FAST_SWITCH_DECORATOR
static intptr_t body(meta_t * abort_stub) {
  return ({
    product(abort_stub, abort_stub->env[0]);
  });
}

static intptr_t runProduct(intptr_t xs) {
  return ({
    HANDLE(body, ({ABORT, done}), (xs));
  });
}

static intptr_t loop(intptr_t xs, intptr_t i, intptr_t a) {
  (i == 0) ? ({
    return a;
  }) : ({
    // TODO: how can we remove the musttail attribute?
    // Invest if we can get ride of taking alloca address in runProduct. Such behavior prevents tail call optimization.
    __attribute__((musttail))
    return loop(xs, i - 1, a + runProduct(xs));
  });
}

static intptr_t run(intptr_t n) {
  return ({
    intptr_t xs = enumerate(1000);
    loop(xs, n, 0);
  });
}

int main(int argc, char *argv[]) {
  printInt(run(readInt()));
  return 0;
}