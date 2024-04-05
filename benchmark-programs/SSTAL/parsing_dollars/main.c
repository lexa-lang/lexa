#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "longjmp.h"

typedef struct node {
    int value;
    struct node* next;
} node;

typedef struct {
  mp_jmpbuf_t *ctx_jb;
  mp_jmpbuf_t *rsp_jb;
} exchanger_t;

typedef struct {
  void (*func)(const intptr_t* const, exchanger_t*, int);
  const intptr_t* env;
  exchanger_t* exchanger;
} handler_t;

typedef struct {
  int (*func)(const intptr_t* const, int);
  const intptr_t* env;
} tail_handler_t;

static intptr_t ret_val;

#define xmalloc(size) ({                \
    void *_ptr = malloc(size);          \
    if (_ptr == NULL) {                 \
        exit(EXIT_FAILURE);             \
    }                                   \
    _ptr;                               \
})

#define newline 10
#define dollar 36

int parse(tail_handler_t *read_stub, tail_handler_t *emit_stub, handler_t *stop_stub, int a) {
  int c = read_stub->func(read_stub->env, 0);
  if (c == dollar) {
    return parse(read_stub, emit_stub, stop_stub, a + 1);
  } else if (c == newline) {
    emit_stub->func(emit_stub->env, a);
    return parse(read_stub, emit_stub, stop_stub, 0);
  } else {
    // Inovke stop
    __asm__ (
      "movq %0, %%rsp\n\t"
      :: "r"(stop_stub->exchanger->ctx_jb->reg_sp)
    );
    stop_stub->func(stop_stub->env, stop_stub->exchanger, 0);
    __builtin_unreachable();
  }
}

static int read(const intptr_t env[4], int _) {
  int* i = (int*)env[0];
  int* j = (int*)env[1];
  int n = (int)env[2];
  handler_t* stop_stub = (handler_t*)env[3];

  if (*i > n) {
    // Inovke stop
    __asm__ (
      "movq %0, %%rsp\n\t"
      :: "r"(stop_stub->exchanger->ctx_jb->reg_sp)
    );
    stop_stub->func(stop_stub->env, stop_stub->exchanger, 0);
    __builtin_unreachable();
  } else if (*j == 0) {
    *i += 1;
    *j = *i;
    return newline;
  } else {
    *j -= 1;
    return dollar;
  }
}

int feed(handler_t *stop_stub, int n, int (*action)(intptr_t*, tail_handler_t*), intptr_t *action_env) {
  int* i = (int*)xmalloc(sizeof(int));
  *i = 0;
  int* j = (int*)xmalloc(sizeof(int));
  *j = 0;
  intptr_t read_env[4] = {(intptr_t)i, (intptr_t)j, (intptr_t)n, (intptr_t)stop_stub};
  tail_handler_t read_closure = {read, read_env};

  int out = action(action_env, &read_closure);
  
  return out;
}

int feed_action(intptr_t self_env[2], tail_handler_t* read_stub) {
  tail_handler_t* emit_stub = (tail_handler_t*)self_env[0];
  handler_t* stop_stub = (handler_t*)self_env[1];
  return parse(read_stub, emit_stub, stop_stub, 0);
}

static void stop(const intptr_t env[0], exchanger_t* exc, int _) {
  ret_val = 0;
  mp_longjmp(exc->ctx_jb);
}

int catch(int (*action)(intptr_t*, handler_t*), intptr_t *action_env) {
  intptr_t stop_env[0];
  mp_jmpbuf_t ctx_jb;
  exchanger_t stop_exc = {&ctx_jb, NULL};
  handler_t stop_closure = {stop, stop_env, &stop_exc};

  int out;
  if (mp_setjmp(stop_closure.exchanger->ctx_jb) == 0) {
    action(action_env, &stop_closure);
    __builtin_unreachable();
  } else {
    out = ret_val;
  }

  return out;
}

int catch_action(intptr_t self_env[2], handler_t* stop_stub) {
  intptr_t n = self_env[0];
  tail_handler_t* emit_stub = (tail_handler_t*)self_env[1];
  intptr_t action_env[2] = {(intptr_t)emit_stub, (intptr_t)stop_stub};
  return feed(stop_stub, n, &feed_action, action_env);
}

static int emit(const intptr_t env[1], int e) {
  int* s = (int*)env[0];
  *s += e;
  return 0;
}

int sum(int (*action)(intptr_t*, tail_handler_t*), intptr_t *action_env) {
  int* s = (int*)xmalloc(sizeof(int));
  *s = 0;
  intptr_t emit_env[1] = {(intptr_t)s};
  tail_handler_t emit_closure = {emit, emit_env};

  action(action_env, &emit_closure);

  return *s;
}

int sum_action(intptr_t self_env[1], tail_handler_t* emit_stub) {
  intptr_t n = self_env[0];
  intptr_t action_env[2] = {n, (intptr_t)emit_stub};
  return catch(&catch_action, action_env);
}

int run(int n){
  intptr_t action_env[1] = {n};
  return sum(&sum_action, action_env);
}

int main(int argc, char *argv[]){
    int out = run(atoi(argv[1]));
    printf("%d\n", out);
    return 0;
}
