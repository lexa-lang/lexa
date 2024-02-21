#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <longjmp.h>
#include <stack_pool.h>

typedef struct {
  mp_jmpbuf_t *ctx_jb;
  mp_jmpbuf_t *rsp_jb;
} exchanger_t;

typedef struct {
  void (*func)(const intptr_t* const, exchanger_t*, int64_t);
  const intptr_t* env;
  exchanger_t* exchanger;
} handler_t;

typedef struct node {
    int64_t value;
    struct node* next;
} node;

typedef struct tree {
    int64_t value;
    struct tree* left;
    struct tree* right;
} tree;

static intptr_t ret_val;

#define xmalloc(size) ({                \
    void *_ptr = malloc(size);          \
    if (_ptr == NULL) {                 \
        exit(EXIT_FAILURE);             \
    }                                   \
    _ptr;                               \
})

node* append(node* xs1, node* xs2) {
  if (xs1 == NULL) {
    return xs2;
  } else {
    node* new_node = (node*)xmalloc(sizeof(node));
    new_node->value = xs1->value;
    new_node->next = append(xs1->next, xs2);
    return new_node;
  }
}

int64_t max(node* xs) {
  if (xs == NULL) {
    return 0;
  } else {
    int64_t m = max(xs->next);
    if (xs->value > m) {
      return xs->value;
    } else {
      return m;
    }
  }
}

tree* make(int64_t n) {
  if (n == 0) {
    return NULL;
  } else {
    tree* t = make(n - 1);
    tree* newTree = (tree*)xmalloc(sizeof(tree));
    newTree->value = n;
    newTree->left = t;
    newTree->right = t;
    return newTree;
  }
}

int64_t operator(int64_t x, int64_t y) {
  return labs(x - (503 * y) + 37) % 1009;
}

void choose(const intptr_t* self_env, exchanger_t* exc, int64_t _) {
  mp_jmpbuf_t* ctx_jb = exc->ctx_jb;
  mp_jmpbuf_t* rsp_jb = exc->rsp_jb;
  void* rsp_jb_sp = rsp_jb->reg_sp;

  node* result1, *result2;
  mp_jmpbuf_t my_jb;
  exc->ctx_jb = &my_jb;
  char* new_sp = dup_stack((char*)rsp_jb_sp);
  rsp_jb->reg_sp = (void*)new_sp;
  ret_val = true;
  if (mp_setjmp(exc->ctx_jb) == 0) {
    mp_longjmp(rsp_jb);
    __builtin_unreachable();
  } else {
    result1 = (node*)ret_val;
  }
  free_stack(new_sp);

  mp_jmpbuf_t my_jb2;
  exc->ctx_jb = &my_jb2;
  rsp_jb->reg_sp = rsp_jb_sp;
  ret_val = false;
  if (mp_setjmp(exc->ctx_jb) == 0) {
    mp_longjmp(rsp_jb);
    __builtin_unreachable();
  } else {
    result2 = (node*)ret_val;
  }
  free(rsp_jb);

  node* result = append(result1, result2);
  ret_val = (intptr_t)result;

  mp_longjmp(ctx_jb);
}

int64_t explore(const intptr_t* self_env, handler_t* choose_stub, tree* t) {
  int64_t* state = (int64_t*)self_env[0];
  if (t == NULL) {
    return *state;
  } else {
    bool decision;
    // Invoke choose
    mp_jmpbuf_t* rsp_jb = (mp_jmpbuf_t*)xmalloc(sizeof(mp_jmpbuf_t));
    choose_stub->exchanger->rsp_jb = rsp_jb;
    if (mp_setjmp(choose_stub->exchanger->rsp_jb) == 0) {
      __asm__ (
        "movq %0, %%rsp\n\t"
        :: "r"(choose_stub->exchanger->ctx_jb->reg_sp)
      );
      choose_stub->func(choose_stub->env, choose_stub->exchanger, 0);
      __builtin_unreachable();
    } else {
      decision = (bool)ret_val;
    }

    tree* next;
    if (decision) {
      next = t->left;
    } else {
      next = t->right;
    }
    *state = operator(*state, t->value);
    return operator(t->value, explore(self_env, choose_stub, next));
  }
}

void body(handler_t* choose_stub) {
  int64_t (*explore_func)(const intptr_t* const, handler_t*, tree*) = (int64_t(*)(const intptr_t* const, handler_t*, tree*))choose_stub->env[1];
  const intptr_t* explore_env = (const intptr_t*)choose_stub->env[2];

  int64_t result = explore_func(explore_env, choose_stub, (tree*)choose_stub->env[0]);

  node* n = (node*)xmalloc(sizeof(node));
  n->value = result;
  n->next = NULL;

  ret_val = (intptr_t)n;

  mp_longjmp(choose_stub->exchanger->ctx_jb);
  __builtin_unreachable();
}

node* paths(const intptr_t* self_env) {
  mp_jmpbuf_t* ctx_jb = (mp_jmpbuf_t*)xmalloc(sizeof(mp_jmpbuf_t));

  exchanger_t *exc = (exchanger_t*)xmalloc(sizeof(exchanger_t));
  exc->ctx_jb = ctx_jb;
  exc->rsp_jb = NULL;

  intptr_t* choose_env = (intptr_t*)xmalloc(sizeof(intptr_t) * 3);
  choose_env[0] = (intptr_t)self_env[0];
  choose_env[1] = (intptr_t)self_env[1];
  choose_env[2] = (intptr_t)self_env[2];
  handler_t* choose_stub = (handler_t*)xmalloc(sizeof(handler_t));
  choose_stub->func = choose;
  choose_stub->env = choose_env;
  choose_stub->exchanger = exc;

  node* out;
  char* new_stack = get_stack();
  if (mp_setjmp(ctx_jb) == 0) {
    __asm__(
      "movq %0, %%rsp\n\t"
      :: "r"(new_stack)
    );
    body(choose_stub);
    __builtin_unreachable();
  } else {
    out = (node*)ret_val;
  }

  free_stack(new_stack);
  
  return out;
}

int64_t run(int64_t n){
  tree* t = make(n);
  int64_t* state = (int64_t*)xmalloc(sizeof(int64_t));
  *state = 0;

  intptr_t* explore_env = (intptr_t*)xmalloc(sizeof(intptr_t));
  explore_env[0] = (intptr_t)state;

  intptr_t* paths_env = (intptr_t*)xmalloc(sizeof(intptr_t) * 3);
  paths_env[0] = (intptr_t)t;
  paths_env[1] = (intptr_t)explore;
  paths_env[2] = (intptr_t)explore_env;


  for (int64_t i = 10; i != 0; i--) {
    *state = max(paths(paths_env));
  }


  return *state;
}

int main(int argc, char *argv[]){
    init_stack_pool();
    int64_t out = run(atoi(argv[1]));
    printf("%d\n", out);
    destroy_stack_pool();
    return 0;
}
