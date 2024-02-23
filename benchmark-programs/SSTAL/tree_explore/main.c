#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <defs.h>
#include <datastructure.h>

static intptr_t ret_val;

tree_t* make(int64_t n) {
  return (n == 0) ? ({
    treeLeaf();
  }) : ({
    tree_t* t = make(n - 1);
    tree_t* newTree = (tree_t*)xmalloc(sizeof(tree_t));
    newTree->value = n;
    newTree->left = t;
    newTree->right = t;
    newTree;
  });
}

int64_t operator(int64_t x, int64_t y) {
  return mathAbs(x - (503 * y) + 37) % 1009;
}

void choose(const intptr_t* self_env, exchanger_t* exc, int64_t _) {
  mp_jmpbuf_t* ctx_jb = exc->ctx_jb;
  mp_jmpbuf_t* rsp_jb = exc->rsp_jb;
  void* rsp_sp = rsp_jb->reg_sp;

  node_t* result = listAppend((node_t*)THROW(rsp_jb, rsp_sp, exc, true), 
                              (node_t*)FINAL_THROW(rsp_jb, exc, false));
  ret_val = (intptr_t)result;

  mp_longjmp(ctx_jb);
}

int64_t explore(intptr_t* const state, tree_t* tree, handler_t* choose_stub) {
  return (treeIsLeaf(tree)) ?
    ({ 
      state[0];
    }) 
    : ({
      tree_t* next = ({
        (RAISE(choose_stub, 0, 0)) ? ({
          treeLeft(tree);
        }) : ({
          treeRight(tree);
        });
      });
      state[0] = operator(state[0], treeValue(tree));
      operator(treeValue(tree), explore(state, next, choose_stub));
    });
}

void body(handler_t* choose_stub) {
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

node_t* paths(intptr_t* const state, tree_t* tree) {
  

  exchanger_t exc;

  handler_def_t choose_defs[1] = {{MULTISHOT, (void*)choose}};
  intptr_t choose_env[2] = {(intptr_t)state, (intptr_t)tree};
  handler_t choose_closure = {choose_defs, choose_env, &exc};
  handler_t* choose_stub = &choose_closure;

  return (node_t*)HANDLE(choose_stub, body);
}

int64_t loop(intptr_t* const state, tree_t* tree, int64_t i) {
  return (i == 0) ? ({
    state[0];
  }) : ({
    state[0] = listMax(paths(state, tree));
    loop(state, tree, i - 1);
  });
}

int64_t run(int64_t n){
  tree_t* tree = make(n);

  int64_t* state = (int64_t*)xmalloc(sizeof(int64_t) * 1);
  state[0] = 0;

  int64_t out = loop(state, tree, 10);
  return out;
}

int main(int argc, char *argv[]){
    init_stack_pool();
    int64_t out = run(atoi(argv[1]));
    printf("%ld\n", out);
    destroy_stack_pool();
    return 0;
}
