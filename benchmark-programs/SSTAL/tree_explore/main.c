#include <defs.h>
#include <datastructure.h>

static i64 make(i64 n) {
  return (n == 0) ? ({
    (i64)treeLeaf();
  }) : ({
    i64 t = make(n - 1);
    (i64)treeNode(n, (tree_t*)t, (tree_t*)t);
  });
}

static i64 operator(i64 x, i64 y) {
  return mathAbs(x - (503 * y) + 37) % 1009;
}

FAST_SWITCH_DECORATOR
i64 choose(i64 env, i64 _, i64 k) {
  return ({
    (i64)listAppend((node_t*)THROW(k, true), 
                          (node_t*)FINAL_THROW(k, false));
  });
}

static i64 explore(i64 state, i64 tree, i64 choice_stub) {
  return (treeIsEmpty((tree_t*)tree)) ?
    ({ 
      ((i64*)state)[0];
    }) 
    : ({
      i64 next = ({
        (RAISE(choice_stub, 0, (0))) ? ({
          (i64)treeLeft((tree_t*)tree);
        }) : ({
          (i64)treeRight((tree_t*)tree);
        });
      });
      ((i64*)state)[0] = operator(((i64*)state)[0], treeValue((tree_t*)tree));
      operator(treeValue((tree_t*)tree), explore(state, next, choice_stub));
    });
}


static int64_t body(i64 choice_stub) {
  return (i64)({
    listNode(
      explore(((meta_t*)choice_stub)->env[0], ((meta_t*)choice_stub)->env[1], choice_stub), 
      listEnd());
  });
}

static i64 paths(i64 state, i64 tree) {
  return HANDLE(body, ({MULTISHOT, choose}), (state, tree));
}

static i64 loop(i64 state, i64 tree, i64 i) {
  return (i == 0) ? ({
    ((i64*)state)[0];
  }) : ({
    ((i64*)state)[0] = listMax((node_t*)paths(state, tree));
    loop(state, tree, i - 1);
  });
}

static i64 run(i64 n){
  i64 tree = make(n);

  i64 state = (i64)xmalloc(sizeof(i64) * 1);
  ((i64*)state)[0] = 0;

  i64 out = loop(state, tree, 10);
  return out;
}

int main(int argc, char *argv[]){
    init_stack_pool();
    printInt(run(readInt()));
    destroy_stack_pool();
    return 0;
}
