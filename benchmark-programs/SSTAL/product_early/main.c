#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <defs.h>
#include <datastructure.h>

static intptr_t ret_val;

node_t* enumerate(int i) {
  return (i < 0) ? ({
    listEnd();
   }) : ({
    listNode(i, enumerate(i - 1));
   });
}

void done(const intptr_t* const env, exchanger_t* exc, int64_t r) {
  ret_val = ({
    r;
  });
  mp_longjmp(exc->ctx_jb);
  __builtin_unreachable();
}

int64_t product(handler_t *abort_stub, node_t* xs) {
  return (listIsEmpty(xs)) ? ({
    0;
  }) : ({
    int64_t y = listHead(xs);
    node_t* ys = listTail(xs);
    (y == 0) ? ({
      RAISE(abort_stub, 0, 0);
    }): ({
      y * product(abort_stub, ys);
    });
  });
}

int64_t body(handler_t *abort_stub) {
  ret_val = ({
    product(abort_stub, (node_t*)abort_stub->env[0]);
  });

  mp_longjmp(abort_stub->exchanger->ctx_jb);
  __builtin_unreachable();
}

int64_t runProduct(node_t* xs) {
  return ({
    intptr_t env[1] = {(intptr_t)xs};
    HANDLE_ONE(body, ABORT, done, env);
  });
}

int64_t loop(node_t* xs, int64_t i, int64_t a) {
  return (i == 0) ? ({
    a;
  }) : ({
    loop(xs, i - 1, a + runProduct(xs));
  });
}

int64_t run(int64_t n) {
  return ({
    node_t* xs = enumerate(1000);
    loop(xs, n, 0);
  });
}

int main(int argc, char *argv[]) {
  printInt(run(readInt()));
  return 0;
}