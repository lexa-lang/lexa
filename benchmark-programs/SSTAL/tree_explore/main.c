#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <defs.h>
#include <datastructure.h>

intptr_t ret_val;

static intptr_t make(intptr_t n) {
  return (n == 0) ? ({
    (intptr_t)treeLeaf();
  }) : ({
    intptr_t t = make(n - 1);
    (intptr_t)treeNode(n, (tree_t*)t, (tree_t*)t);
  });
}

static intptr_t operator(intptr_t x, intptr_t y) {
  return mathAbs(x - (503 * y) + 37) % 1009;
}

void choose(intptr_t env, intptr_t _, exchanger_t* exc) {
  mp_jmpbuf_t* ctx_jb = exc->ctx_jb;
  mp_jmpbuf_t* rsp_jb = exc->rsp_jb;
  void* rsp_sp = rsp_jb->reg_sp;

  node_t* result = listAppend((node_t*)THROW(rsp_jb, rsp_sp, exc, true), 
                              (node_t*)FINAL_THROW(rsp_jb, rsp_sp, exc, false));
  ret_val = (intptr_t)result;

  mp_longjmp(ctx_jb);
}

static intptr_t explore(intptr_t state, intptr_t tree, handler_t* choose_stub) {
  return (treeIsEmpty((tree_t*)tree)) ?
    ({ 
      ((intptr_t*)state)[0];
    }) 
    : ({
      intptr_t next = ({
        (RAISE(choose_stub, 0, 0)) ? ({
          (intptr_t)treeLeft((tree_t*)tree);
        }) : ({
          (intptr_t)treeRight((tree_t*)tree);
        });
      });
      ((intptr_t*)state)[0] = operator(((intptr_t*)state)[0], treeValue((tree_t*)tree));
      operator(treeValue((tree_t*)tree), explore(state, next, choose_stub));
    });
}

static int64_t body(handler_t* choose_stub) {
  ret_val = (intptr_t)({
    listNode(
      #pragma clang diagnostic ignored "-Wint-conversion"
      explore(choose_stub->env[0], choose_stub->env[1], choose_stub), 
      #pragma clang diagnostic warning "-Wint-conversion"
      listEnd());
  });

  mp_longjmp(choose_stub->exchanger->ctx_jb);
  __builtin_unreachable();
}

static intptr_t paths(intptr_t state, intptr_t tree) {
  intptr_t choose_env[2] = {state, tree};

  return HANDLE_ONE(body, MULTISHOT, choose, choose_env);
}

static intptr_t loop(intptr_t state, intptr_t tree, intptr_t i) {
  return (i == 0) ? ({
    ((intptr_t*)state)[0];
  }) : ({
    ((intptr_t*)state)[0] = listMax((node_t*)paths(state, tree));
    loop(state, tree, i - 1);
  });
}

static intptr_t run(intptr_t n){
  intptr_t tree = make(n);

  intptr_t state = (intptr_t)xmalloc(sizeof(intptr_t) * 1);
  ((intptr_t*)state)[0] = 0;

  intptr_t out = loop(state, tree, 10);
  return out;
}

int main(int argc, char *argv[]){
    init_stack_pool();
    printInt(run(readInt()));
    destroy_stack_pool();
    return 0;
}
