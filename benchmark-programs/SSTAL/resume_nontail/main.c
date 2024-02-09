#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <longjmp.h>
#include <stdbool.h>

#define STACK_SIZE 4096

typedef struct {
  intptr_t *funcs; // op
  intptr_t *env; // n, s
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

int loop(handler_t *hdl_stub, int i, int s) {
  if (i == 0) {
    return s;
  } else {
    // invoke op
    if (mp_setjmp(&hdl_stub->rsp_jb) == 0) {
      ctr_ctx.is_ret = false;
      ctr_ctx.payload.invocation.index = 0;
      ctr_ctx.payload.invocation.arg = i;
      mp_longjmp(&hdl_stub->ctx_jb);
      __builtin_unreachable();
    } else {
      // the throwed back value is ignored
    }
    return loop(hdl_stub, i - 1, s);
  }
}

int op(intptr_t env[0], handler_t *rsp_stub, int x) {
  int y;
  if (mp_setjmp(&rsp_stub->ctx_jb) == 0) {
    ctr_ctx.is_ret = true; // not necessary
    ctr_ctx.payload.ret_val = 0;
    mp_longjmp(&rsp_stub->rsp_jb);
  } else {
    if (ctr_ctx.is_ret) {
      y = ctr_ctx.payload.ret_val;
    } else {
      size_t index = ctr_ctx.payload.invocation.index;
      void* func = (void*)rsp_stub->funcs[index];
      intptr_t arg = ctr_ctx.payload.invocation.arg;
      y = ((int(*)(intptr_t*, handler_t*, int))func)(env, rsp_stub, arg);
    }
  }

  // mod(abs(x - (503 * y) + 37), 1009)
  return (abs(x - (503 * y) + 37)) % 1009;
}

void body(handler_t *hdl_stub) {
  int n = hdl_stub->env[0];
  int s = hdl_stub->env[1];
  for (int i = n; i != 0; i--) {
    if (mp_setjmp(&hdl_stub->rsp_jb) == 0) {
      ctr_ctx.is_ret = false;
      ctr_ctx.payload.invocation.index = 0;
      ctr_ctx.payload.invocation.arg = i;
      mp_longjmp(&hdl_stub->ctx_jb);
      __builtin_unreachable();
    } else {
      // the throwed back value is ignored
    }
  }
  int out = s;
  // int out = loop(hdl_stub, hdl_stub->env[0], hdl_stub->env[1]);
  ctr_ctx.is_ret = true;
  ctr_ctx.payload.ret_val = out;
  mp_longjmp(&hdl_stub->ctx_jb);
  __builtin_unreachable();
}

int run(int n, int s) {
  intptr_t* funcs = (intptr_t*)malloc(sizeof(intptr_t));
  if (!funcs) {
    fprintf(stderr, "Memory allocation failed\n");
    exit(EXIT_FAILURE);
  }
  funcs[0] = (intptr_t)&op;

  intptr_t* env = (intptr_t*)malloc(2 * sizeof(intptr_t));
  if (!env) {
    fprintf(stderr, "Memory allocation failed\n");
    exit(EXIT_FAILURE);
  }
  env[0] = n;
  env[1] = s;

  handler_t* closure = (handler_t*)malloc(sizeof(handler_t));
  if (!closure) {
    fprintf(stderr, "Memory allocation failed\n");
    exit(EXIT_FAILURE);
  }
  closure->funcs = funcs;
  closure->env = env;

  int result;
  if (mp_setjmp(&closure->ctx_jb) == 0) {
    char* new_stack = (char*)aligned_alloc(STACK_SIZE, STACK_SIZE);
    if (!new_stack) {
      fprintf(stderr, "Memory allocation failed\n");
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
      result = ctr_ctx.payload.ret_val;
    } else {
      size_t index = ctr_ctx.payload.invocation.index;
      void* func = (void*)closure->funcs[index];
      intptr_t arg = ctr_ctx.payload.invocation.arg;
      result = ((int(*)(intptr_t*, handler_t*, int))func)(env, closure, arg);
    }
  }

  return result;
}

int repeat(int n){
  int s = 0;
  for (int l = 1000; l != 0; l--) {
    s = run(n, s);
  }
  return s;
}

int main(int argc, char *argv[]){
    int out = repeat(atoi(argv[1]));
    printf("%d\n", out);
    return 0;
}