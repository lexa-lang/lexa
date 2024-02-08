#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <longjmp.h>
#include <stdbool.h>

typedef struct {
  intptr_t funcs[1]; // done
  intptr_t env[1]; // xs
  mp_jmpbuf_t* jb;
} closure_t;

typedef struct node {
    int value;
    struct node* next;
} node;

typedef struct {
  bool is_ret;
  union {
    intptr_t ret_val;
    struct {
      closure_t* closure;
      size_t index;
      intptr_t arg;
    } invocation;
  } payload;
} ctr_ctx_t;

ctr_ctx_t ctr_ctx;

node* enumerate(int n) {
    node* head = NULL;
    for (int i = 0; i < n; i++) {
        node* newNode = (node*)malloc(sizeof(node));
        if (!newNode) {
            fprintf(stderr, "Memory allocation failed\n");
            exit(EXIT_FAILURE);
        }
        newNode->value = i;
        newNode->next = head; // New node points to the previous head
        head = newNode; // New node becomes the new head
    }
    return head; // Return the head of the list
}

int done(closure_t *handler_closure, int r) {
  return r;
}

int product(closure_t *handler_closure, node* xs) {
  if (xs == NULL) {
    return 1;
  } else {
    if (xs->value == 0) {
      // Invoke the handler
      ctr_ctx.is_ret = false;
      ctr_ctx.payload.invocation.closure = handler_closure;
      ctr_ctx.payload.invocation.index = 0;
      ctr_ctx.payload.invocation.arg = 0;
      mp_longjmp(handler_closure->jb);
      __builtin_unreachable();
    } else {
      // Recurse
      return xs->value * product(handler_closure, xs->next);
    }
  }
}

void body(closure_t *handler_closure) {
  int out = product(handler_closure, (node*)handler_closure->env[0]);
  ctr_ctx.is_ret = true;
  ctr_ctx.payload.ret_val = out;
  mp_longjmp(handler_closure->jb);
  __builtin_unreachable();
}

int runProduct(node* xs) {
  // Stack-allocate the closure for the handler
  mp_jmpbuf_t jb;
  closure_t closure = {(intptr_t)&done, {(intptr_t)xs}, &jb};
  int out;
  if (mp_setjmp(closure.jb) == 0) {
    body(&closure);
    __builtin_unreachable();
  } else {
    if (ctr_ctx.is_ret) {
      out = ctr_ctx.payload.ret_val;
    } else {
      closure_t* handler_closure = ctr_ctx.payload.invocation.closure;
      intptr_t index = ctr_ctx.payload.invocation.index;
      intptr_t arg = ctr_ctx.payload.invocation.arg;
      intptr_t* funcs = handler_closure->funcs;
      out = ((int (*)(closure_t*, intptr_t))funcs[index])(handler_closure, arg);
    }
  }

  return out;
}

int run(int n){
  int a = 0;
  node* xs = enumerate(1000);
  for (int i = 0; i < n; i++) {
    a += runProduct(xs);
  }
  return a;
}

int main(int argc, char *argv[]){
    int out = run(atoi(argv[1]));
    printf("%d\n", out);
    return 0;
}