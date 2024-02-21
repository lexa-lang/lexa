#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <longjmp.h>
#include <stdbool.h>

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

static intptr_t ret_val;

#define xmalloc(size) ({                \
    void *_ptr = malloc(size);          \
    if (_ptr == NULL) {                 \
        exit(EXIT_FAILURE);             \
    }                                   \
    _ptr;                               \
})

node* enumerate(int n) {
    node* head = NULL;
    for (int i = 0; i < n; i++) {
        node* newNode = (node*)xmalloc(sizeof(node));
        newNode->value = i;
        newNode->next = head; // New node points to the previous head
        head = newNode; // New node becomes the new head
    }
    return head; // Return the head of the list
}

void done(const intptr_t* const env, exchanger_t* exc, int64_t r) {
  ret_val = r;
  mp_longjmp(exc->ctx_jb);
  __builtin_unreachable();
}

int64_t product(handler_t *done_stub, node* xs) {
  if (xs == NULL) {
    return 0;
  } else {
    if (xs->value == 0) {
      // invoke done
      __asm__ (
        "movq %0, %%rsp\n\t"
        :: "r"(done_stub->exchanger->ctx_jb->reg_sp)
      );
      done_stub->func(done_stub->env, done_stub->exchanger, 0);
      __builtin_unreachable();
    } else {
      return xs->value * product(done_stub, xs->next);
    }
  }
}

void body(handler_t *done_stub) {
  int64_t out = product(done_stub, (node*)done_stub->env[0]);
  ret_val = out;

  mp_longjmp(done_stub->exchanger->ctx_jb);
  __builtin_unreachable();
}

int64_t runProduct(node* xs) {
  
  exchanger_t *exc = &(exchanger_t){.ctx_jb = &(mp_jmpbuf_t){}, .rsp_jb = NULL};

  intptr_t done_env[1] = {(intptr_t)xs};
  handler_t *done_stub = &(handler_t){.func = done, .env = done_env, .exchanger = exc};

  int64_t out;
  if (mp_setjmp(exc->ctx_jb) == 0) {
    body(done_stub);
    __builtin_unreachable();
  } else {
    out = ret_val;
  }

  return out;
}

int64_t run(int64_t n) {
  int64_t a = 0;
  node* xs = enumerate(1000);
  for (int i = 0; i < n; i++) {
    a += runProduct(xs);
  }
  return a;
}

int main(int argc, char *argv[]) {
    int out = run(atoi(argv[1]));
    printf("%d\n", out);
    return 0;
}