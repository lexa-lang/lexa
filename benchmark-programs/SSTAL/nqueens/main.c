#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <longjmp.h>
#include <stack_pool.h>

typedef struct node {
    int value;
    struct node* next;
} node;

typedef struct {
  intptr_t *funcs; // fail, pick
  intptr_t *env; // n
  mp_jmpbuf_t *ctx_jb;
  mp_jmpbuf_t *rsp_jb;
} handler_t;

typedef struct {
  bool is_ret;
  union {
    intptr_t ret_val;
    struct {
      size_t index;
      intptr_t arg;
    } invocation;
  } payload;
} ctr_ctx_t;

ctr_ctx_t ctr_ctx;
intptr_t ret_val;

void* xmalloc(size_t size) {
  void* p = malloc(size);
  if (!p) {
    fprintf(stderr, "Memory allocation failed\n");
    exit(EXIT_FAILURE);
  }
  return p;
}

bool safe(int queen, int diag, node* xs) {
  void *rsp;
  // __asm__(
  //   "movq %%rsp, %0\n\t"
  //   : "=r"(rsp)
  // );
  // if (STACK_SIZE - (intptr_t)rsp % STACK_SIZE > largest_stack_size) {
  //   largest_stack_size = STACK_SIZE - (intptr_t)rsp % STACK_SIZE;
  // }
  if (xs == NULL) {
    return true;
  } else {
    if (queen != xs->value && queen != xs->value + diag && queen != xs->value - diag) {
      return safe(queen, diag + 1, xs->next);
    } else {
        return false;
    }
  }
}

node* place(handler_t *handler_closure, int size, int column) {
  if (column == 0) {
    return NULL;
  } else {
    int next;
    node* rest = place(handler_closure, size, column - 1);
    // Invoke pick
    mp_jmpbuf_t* rsp_jb = (mp_jmpbuf_t*)xmalloc(sizeof(mp_jmpbuf_t));
    handler_closure->rsp_jb = rsp_jb;
    if (mp_setjmp(handler_closure->rsp_jb) == 0) {
      __asm__ (
        "movq %1, %%rsp\n\t"
        "jmp *%0\n\t"
        : // No output operands
        : "r"(handler_closure->funcs[1]), "r"(handler_closure->ctx_jb->reg_sp),
        "D"(handler_closure->env), "S"(handler_closure), "d"(size)
      );
      __builtin_unreachable();
    } else {
      next = ret_val;
    }

    if (safe(next, 1, rest)) {
      node* newNode = (node*)xmalloc(sizeof(node));
      newNode->value = next;
      newNode->next = rest;
      return newNode;
    } else {
      // Invoke fail
      __asm__ (
        "movq %1, %%rsp\n\t"
        "jmp *%0\n\t"
        : // No output operands
        : "r"(handler_closure->funcs[0]), "r"(handler_closure->ctx_jb->reg_sp),
        "D"(handler_closure->env), "S"(handler_closure), "d"(0)
      );
      __builtin_unreachable();
    }
  }
}

// no prologue or epilogue
void body(handler_t *hdl_stub) {
  place(hdl_stub, hdl_stub->env[0], hdl_stub->env[0]);
  ret_val = 1;
  mp_longjmp(hdl_stub->ctx_jb);
  __builtin_unreachable();
}

// no prologue or epilogue
void fail(intptr_t env[1], handler_t *rsp_stub, int r) {
  ret_val = 0;
  mp_longjmp(rsp_stub->ctx_jb);
}

// no prologue or epilogue
void pick(intptr_t env[1], handler_t *rsp_stub, int size) {
  mp_jmpbuf_t* ctx_jb = rsp_stub->ctx_jb;
  mp_jmpbuf_t* rsp_jb = rsp_stub->rsp_jb;
  rsp_stub->ctx_jb = NULL;
  rsp_stub->rsp_jb = NULL;
  void* rsp_jb_sp = rsp_jb->reg_sp;

  mp_jmpbuf_t my_jb;
  int a = 0;
  for (int i = 1; i <= size; i++) {
    int result;
    char* new_sp = dup_stack(rsp_jb_sp);
    rsp_jb->reg_sp = (void*)new_sp;

    ret_val = i;
    rsp_stub->ctx_jb = &my_jb;
    if (mp_setjmp(&my_jb) == 0) {
      mp_longjmp(rsp_jb);
      __builtin_unreachable();
    } else {
      result = ret_val;
    }
    free_stack(new_sp);
    a += result;
  }
  free(rsp_jb);

  ret_val = a;
  mp_longjmp(ctx_jb);
}

int run(int n){
  intptr_t* funcs = (intptr_t*)xmalloc(2 * sizeof(intptr_t));
  funcs[0] = (intptr_t)&fail;
  funcs[1] = (intptr_t)&pick;

  intptr_t* env = (intptr_t*)xmalloc(sizeof(intptr_t));
  env[0] = n;

  handler_t* closure = (handler_t*)xmalloc(sizeof(handler_t));
  closure->funcs = funcs;
  closure->env = env;

  int out;

  mp_jmpbuf_t my_jb;
  closure->ctx_jb = &my_jb;

  char* new_stack = get_stack();
  if (mp_setjmp(&my_jb) == 0) {
    __asm__(
      "movq %0, %%rsp\n\t"
      : // No output operands
      : "r"(new_stack)
    );
    body(closure);
    __builtin_unreachable();
  } else {
    out = ret_val;
  }
  free(funcs);
  free(env);
  free(closure);
  
  free_stack(new_stack);

  return out;
}

int main(int argc, char *argv[]){
    init_stack_pool();
    int out = run(atoi(argv[1]));
    printf("%d\n", out);
    // printf("Largest stack size: %zu\n", largest_stack_size);
    destroy_stack_pool();
    return 0;
}
