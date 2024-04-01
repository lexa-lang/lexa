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
  void (*func1)(const intptr_t* const, exchanger_t*, int);
  void (*func2)(const intptr_t* const, exchanger_t*, int);
  const intptr_t* env;
  exchanger_t* exchanger;
} handler_t;

static intptr_t ret_val;

#define xmalloc(size) ({                \
    void *_ptr = malloc(size);          \
    if (_ptr == NULL) {                 \
        exit(EXIT_FAILURE);             \
    }                                   \
    _ptr;                               \
})

typedef struct {
  int a;
  int b;
  int c;
} triple_t;

int64_t hash(triple_t *t) {
  return ((53 * t->a) + 2809 * t->b + 148877 * t->c) % 1000000007;
}

static int64_t choice(handler_t* stub, int64_t n) {
  if (n < 1) {
    // invoke fail
    __asm__ (
      "movq %0, %%rsp\n\t"
      :: "r"(stub->exchanger->ctx_jb->reg_sp)
    );
    stub->func2(stub->env, stub->exchanger, 0);
    __builtin_unreachable();
  } else {
    // invoke flip
    mp_jmpbuf_t* rsp_jb = (mp_jmpbuf_t*)xmalloc(sizeof(mp_jmpbuf_t));
    stub->exchanger->rsp_jb = rsp_jb;
    if (mp_setjmp(stub->exchanger->rsp_jb) == 0) {
      __asm__ (
        "movq %0, %%rsp\n\t"
        :: "r"(stub->exchanger->ctx_jb->reg_sp)
      );
      stub->func1(stub->env, stub->exchanger, 0);
      __builtin_unreachable();
    }
    if ((bool)ret_val) {
      return n;
    } else {
      // TOOD: how to make LLVM optimize without annotation?
      __attribute__((musttail))
      return choice(stub, n - 1);
    }
  }
}

static triple_t* triple(handler_t* stub, int n, int s) {
  int64_t i = choice(stub, n);
  int64_t j = choice(stub, i - 1);
  int64_t k = choice(stub, j - 1);
  if (i + j + k == s) {
    triple_t* t = (triple_t*)xmalloc(sizeof(triple_t));
    t->a = i;
    t->b = j;
    t->c = k;
    return t;
  } else {
    // invoke fail
    __asm__ (
      "movq %0, %%rsp\n\t"
      :: "r"(stub->exchanger->ctx_jb->reg_sp)
    );
    stub->func2(stub->env, stub->exchanger, 0);
    __builtin_unreachable();
  }
}

static void body(handler_t* stub) {
  triple_t* t = triple(stub, stub->env[0], stub->env[1]);
  int64_t result = hash(t);
  
  ret_val = (intptr_t)result;
  mp_longjmp(stub->exchanger->ctx_jb);
  __builtin_unreachable();
}

static void flip(const intptr_t* const env, exchanger_t* exc, int _) {
  mp_jmpbuf_t* ctx_jb = exc->ctx_jb;
  mp_jmpbuf_t* rsp_jb = exc->rsp_jb;
  void* rsp_jb_sp = rsp_jb->reg_sp;

  int64_t result1, result2;
  mp_jmpbuf_t my_jb;
  exc->ctx_jb = &my_jb;
  char* new_sp = dup_stack((char*)rsp_jb_sp);
  rsp_jb->reg_sp = (void*)new_sp;
  ret_val = true;
  if (mp_setjmp(exc->ctx_jb) == 0) {
    mp_longjmp(rsp_jb);
    __builtin_unreachable();
  } else {
    result1 = (int64_t)ret_val;
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
    result2 = (int64_t)ret_val;
  }
  free(rsp_jb);

  int64_t result = (result1 + result2) % 1000000007;
  ret_val = (intptr_t)result;

  mp_longjmp(ctx_jb);
}

static void fail(const intptr_t* const env, exchanger_t* exc, int _) {
  ret_val = 0;
  mp_longjmp(exc->ctx_jb);
  __builtin_unreachable();
}

static int64_t run(int64_t n, int64_t s){
  mp_jmpbuf_t* ctx_jb = (mp_jmpbuf_t*)xmalloc(sizeof(mp_jmpbuf_t));

  exchanger_t *exc = (exchanger_t*)xmalloc(sizeof(exchanger_t));
  exc->ctx_jb = ctx_jb;
  exc->rsp_jb = NULL;

  intptr_t* hdl_env = (intptr_t*)xmalloc(sizeof(intptr_t) * 2);
  hdl_env[0] = (intptr_t)n;
  hdl_env[1] = (intptr_t)s;
  handler_t* hdl_stub = (handler_t*)xmalloc(sizeof(handler_t));
  hdl_stub->func1 = flip;
  hdl_stub->func2 = fail;
  hdl_stub->env = hdl_env;
  hdl_stub->exchanger = exc;

  int64_t out;
  char* new_stack = get_stack();
  if (mp_setjmp(ctx_jb) == 0) {
    __asm__(
      "movq %0, %%rsp\n\t"
      :: "r"(new_stack)
    );
    body(hdl_stub);
    __builtin_unreachable();
  } else {
    out = (int64_t)ret_val;
  }

  free_stack(new_stack);

  return out;
}

int main(int argc, char *argv[]){
    init_stack_pool();
    int n = atoi(argv[1]);
    int out = run(n, n);
    printf("%d\n", out);
    destroy_stack_pool();
    return 0;
}
