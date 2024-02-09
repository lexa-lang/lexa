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

#define newline 10
#define dollar 36

int parse(handler_t *read_stub, handler_t *emit_stub, handler_t *stop_stub, int a) {
  int c = ((int(*)(intptr_t*, int))read_stub->funcs[0])((intptr_t*)read_stub->env, 0);
  if (c == dollar) {
    return parse(read_stub, emit_stub, stop_stub, a + 1);
  } else if (c == newline) {
    ((int(*)(intptr_t*, int))emit_stub->funcs[0])((intptr_t*)emit_stub->env, a);
    return parse(read_stub, emit_stub, stop_stub, 0);
  } else {
    // Inovke stop
    ctr_ctx.is_ret = false;
    ctr_ctx.payload.invocation.index = 0;
    mp_longjmp(&stop_stub->ctx_jb);
    __builtin_unreachable();
  }
}

int read(intptr_t env[4], int _) {
  int* i = (int*)env[0];
  int* j = (int*)env[1];
  int n = (int)env[2];
  handler_t* stop_stub = (handler_t*)env[3];

  if (*i > n) {
    // Inovke stop
    ctr_ctx.is_ret = false;
    ctr_ctx.payload.invocation.index = 0;
    mp_longjmp(&stop_stub->ctx_jb);
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

int feed(handler_t *stop_stub, int n, int (*action)(handler_t*, intptr_t*), intptr_t *action_env) {
  int* i = (int*)malloc(sizeof(int));
  if (!i) {
    fprintf(stderr, "Memory allocation failed\n");
    exit(EXIT_FAILURE);
  }
  *i = 0;
  int* j = (int*)malloc(sizeof(int));
  if (!j) {
    fprintf(stderr, "Memory allocation failed\n");
    exit(EXIT_FAILURE);
  }
  *j = 0;
  intptr_t env[4] = {(intptr_t)i, (intptr_t)j, (intptr_t)n, (intptr_t)stop_stub};
  intptr_t funcs[1] = {(intptr_t)read};
  handler_t read_closure = {funcs, env};

  int out = action(&read_closure, action_env);
  
  return out;
}

int feed_action(handler_t* read_stub, intptr_t env[2]) {
  intptr_t emit_stub = env[0];
  intptr_t stop_stub = env[1];
  return parse(read_stub, (handler_t*)emit_stub, (handler_t*)stop_stub, 0);
}

int stop(intptr_t env[0], int _) {
  return 0;
}

int catch(int (*action)(handler_t*, intptr_t*), intptr_t *action_env) {
  intptr_t stop_env[0];
  intptr_t funcs[1] = {(intptr_t)stop};
  handler_t stop_closure = {funcs, stop_env};

  int out;
  if (mp_setjmp(&stop_closure.ctx_jb) == 0) {
    action(&stop_closure, action_env);
    __builtin_unreachable();
  } else {
    if (ctr_ctx.is_ret) {
      out = ctr_ctx.payload.ret_val;
    } else {
      intptr_t index = ctr_ctx.payload.invocation.index;
      intptr_t arg = ctr_ctx.payload.invocation.arg;
      intptr_t* funcs = stop_closure.funcs;
      out = ((int (*)(intptr_t*, handler_t*, int))funcs[index])(stop_env, &stop_closure, arg);
    }
  }

  return out;
}

int catch_action(handler_t* stop_stub, intptr_t env[2]) {
  intptr_t n = env[0];
  intptr_t emit_stub = env[1];
  intptr_t action_env[2] = {emit_stub, (intptr_t)stop_stub};
  return feed(stop_stub, n, &feed_action, action_env);
}

int emit(intptr_t env[1], int e) {
  int* s = (int*)env[0];
  *s += e;
  return 0;
}

int sum(int (*action)(handler_t*, intptr_t*), intptr_t *action_env) {
  int* s = (int*)malloc(sizeof(int));
  if (!s) {
    fprintf(stderr, "Memory allocation failed\n");
    exit(EXIT_FAILURE);
  }
  *s = 0;
  intptr_t env[1] = {(intptr_t)s};
  intptr_t funcs[1] = {(intptr_t)emit};
  handler_t emit_closure = {funcs, env};

  action(&emit_closure, action_env);

  return *s;
}

int sum_action(handler_t* emit_stub, intptr_t env[1]) {
  intptr_t n = env[0];
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
