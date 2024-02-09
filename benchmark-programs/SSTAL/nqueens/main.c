#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <longjmp.h>

//TODO: Investigate how to set to smaller
#define STACK_SIZE 4096

typedef struct node {
    int value;
    struct node* next;
} node;

typedef struct {
  intptr_t *funcs; // fail, pick
  intptr_t *env; // n
  mp_jmpbuf_t ctx_jb;
  mp_jmpbuf_t rsp_jb;
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

char* dup_stack(char* sp) {
    char* new_stack = (char*)aligned_alloc(STACK_SIZE, STACK_SIZE);
    if (!new_stack) {
        fprintf(stderr, "Failed to allocate memory for the new stack.\n");
        exit(EXIT_FAILURE);
    }
    size_t num_bytes = STACK_SIZE - (intptr_t)sp % STACK_SIZE;
    char* new_sp = new_stack + STACK_SIZE - num_bytes;
    memcpy(new_sp, sp, num_bytes);
    return new_sp;
}

bool safe(int queen, int diag, node* xs) {
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
    if (mp_setjmp(&handler_closure->rsp_jb) == 0) {
      ctr_ctx.is_ret = false;
      ctr_ctx.payload.invocation.index = 1;
      ctr_ctx.payload.invocation.arg = (intptr_t)size;
      mp_longjmp(&handler_closure->ctx_jb);
      __builtin_unreachable();
    } else {
      next = ctr_ctx.payload.ret_val;
    }

    if (safe(next, 1, rest)) {
      node* newNode = (node*)malloc(sizeof(node));
      if (!newNode) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(EXIT_FAILURE);
      }
      newNode->value = next;
      newNode->next = rest;
      return newNode;
    } else {
      // Invoke fail
      ctr_ctx.is_ret = false;
      ctr_ctx.payload.invocation.index = 0;
      ctr_ctx.payload.invocation.arg = 0;
      mp_longjmp(&handler_closure->ctx_jb);
      __builtin_unreachable();
    }
  }
}

void body(handler_t *hdl_stub) {
  place(hdl_stub, hdl_stub->env[0], hdl_stub->env[0]);
  ctr_ctx.is_ret = true;
  ctr_ctx.payload.ret_val = 1;
  mp_longjmp(&hdl_stub->ctx_jb);
  __builtin_unreachable();
}

int fail(intptr_t env[1], handler_t *rsp_stub, int r) {
  return 0;
}

int pick(intptr_t env[1], handler_t *rsp_stub, int size) {
  mp_jmpbuf_t rsp_jb_dup;
  memcpy(&rsp_jb_dup, &rsp_stub->rsp_jb, sizeof(mp_jmpbuf_t));
  rsp_jb_dup.reg_sp = (void*)dup_stack((char*)rsp_stub->rsp_jb.reg_sp);
  int a = 0;
  for (int i = 1; i <= size; i++) {
    int result;
    void* new_sp;
    if (mp_setjmp(&rsp_stub->ctx_jb) == 0) {
      new_sp = (void*)dup_stack((char*)rsp_jb_dup.reg_sp);
      rsp_jb_dup.reg_sp = new_sp;

      ctr_ctx.is_ret = true; // not necessary
      ctr_ctx.payload.ret_val = i;
      mp_longjmp(&rsp_jb_dup);
      __builtin_unreachable();
    } else {
      if (ctr_ctx.is_ret) {
        result = ctr_ctx.payload.ret_val;
      } else {
        size_t index = ctr_ctx.payload.invocation.index;
        void* func = (void*)rsp_stub->funcs[index];
        intptr_t arg = ctr_ctx.payload.invocation.arg;
        result = ((int(*)(intptr_t*, handler_t*, int))func)(env, rsp_stub, arg);
      }
      // Optionally free the stack
      // char* stack = (char*)((intptr_t)new_sp / STACK_SIZE * STACK_SIZE);
      // free(stack);
    }
    a += result;
  }

  return a;
}

int run(int n){
  intptr_t* funcs = (intptr_t*)malloc(2 * sizeof(intptr_t));
  if (!funcs) {
    fprintf(stderr, "Memory allocation failed\n");
    exit(EXIT_FAILURE);
  }
  funcs[0] = (intptr_t)&fail;
  funcs[1] = (intptr_t)&pick;

  intptr_t* env = (intptr_t*)malloc(sizeof(intptr_t));
  if (!env) {
    fprintf(stderr, "Memory allocation failed\n");
    exit(EXIT_FAILURE);
  }
  env[0] = n;

  handler_t* closure = (handler_t*)malloc(sizeof(handler_t));
  if (!closure) {
    fprintf(stderr, "Memory allocation failed\n");
    exit(EXIT_FAILURE);
  }
  closure->funcs = funcs;
  closure->env = env;

  int out;
  if (mp_setjmp(&closure->ctx_jb) == 0) {
    char* new_stack = (char*)aligned_alloc(STACK_SIZE, STACK_SIZE);
    if (!new_stack) {
      fprintf(stderr, "Failed to allocate memory for the new stack.\n");
      exit(EXIT_FAILURE);
    }
    char* new_sp = new_stack + STACK_SIZE;
    __asm__(
      "movq %0, %%rsp\n\t"
      : // No output operands
      : "r"(new_sp)
    );
    body(closure);
    __builtin_unreachable();
  } else {
    if (ctr_ctx.is_ret) {
      out = ctr_ctx.payload.ret_val;
    } else {
        size_t index = ctr_ctx.payload.invocation.index;
        void* func = (void*)closure->funcs[index];
        intptr_t arg = ctr_ctx.payload.invocation.arg;
        out = ((int(*)(intptr_t*, handler_t*, int))func)(env, closure, arg);
    }
  }

  return out;
}

int main(int argc, char *argv[]){
    int out = run(atoi(argv[1]));
    printf("%d\n", out);
    return 0;
}
