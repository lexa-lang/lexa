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
void done(const intptr_t* const env, intptr_t r, exchanger_t* exc) {
  ret_val = ({
    r;
  });
  RESTORE_CONTEXT(exc->ctx_jb);
  __builtin_unreachable();
}

static intptr_t product(handler_t *abort_stub, intptr_t xs) {
  return (listIsEmpty((node_t*)xs)) ? ({
    0;
  }) : ({
    intptr_t y = (intptr_t)listHead((node_t*)xs);
    intptr_t ys = (intptr_t)listTail((node_t*)xs);
    (y == 0) ? ({
      RAISE(abort_stub, 0, 0);
    }): ({
      y * product(abort_stub, ys);
    });
  });
}

FAST_SWITCH_DECORATOR
static intptr_t body(handler_t * abort_stub) {
  ret_val = ({
    product(abort_stub, abort_stub->env[0]);
  });

  RESTORE_CONTEXT(abort_stub->exchanger->ctx_jb);
  __builtin_unreachable();
}

static intptr_t runProduct(intptr_t xs) {
  return ({
    HANDLE_ONE(body, ABORT, done, xs);
  });
}

static intptr_t loop(intptr_t xs, intptr_t i, intptr_t a) {
  (i == 0) ? ({
    return a;
  }) : ({
    // TODO: how can we remove the musttail attribute?
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