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
  mp_jmpbuf_t *ctx_jb;
  mp_jmpbuf_t *rsp_jb;
} exchanger_t;

static intptr_t ret_val;

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

static node* place(
  void (*const fail)(const intptr_t* const, exchanger_t*, int),
  void (*const pick)(const intptr_t* const, exchanger_t*, int),
  const intptr_t* const env,
  exchanger_t *exchanger, int size, int column) {
  if (column == 0) {
    return NULL;
  } else {
    int next;
    node* rest = place(fail, pick, env, exchanger, size, column - 1);
    // Invoke pick
    mp_jmpbuf_t* rsp_jb = (mp_jmpbuf_t*)xmalloc(sizeof(mp_jmpbuf_t));
    exchanger->rsp_jb = rsp_jb;
    if (mp_setjmp(exchanger->rsp_jb) == 0) {
      __asm__ (
        "movq %0, %%rsp\n\t"
        :: "r"(exchanger->ctx_jb->reg_sp)
      );
      pick(env, exchanger, size);
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
      __asm__ (
        "movq %0, %%rsp\n\t"
        :: "r"(exchanger->ctx_jb->reg_sp)
      );
      fail(env, exchanger, 0);
      __builtin_unreachable();
    }
  }
}

__attribute__((preserve_none))
static void body(
  void (*const fail)(const intptr_t* const, exchanger_t*, int),
  void (*const pick)(const intptr_t* const, exchanger_t*, int),
  const intptr_t* const env,
  exchanger_t *exchanger) {
  place(fail, pick, env, exchanger, env[0], env[0]);
  ret_val = 1;
  mp_longjmp(exchanger->ctx_jb);
  __builtin_unreachable();
}

__attribute__((preserve_none))
__attribute__((always_inline))
static inline void fail(const intptr_t* const env, exchanger_t *exchanger, int r) {
  ret_val = 0;
  mp_longjmp(exchanger->ctx_jb);
}

__attribute__((preserve_none))
__attribute__((always_inline))
static inline void pick(const intptr_t* const env, exchanger_t *exchanger, int size) {
  mp_jmpbuf_t* ctx_jb = exchanger->ctx_jb;
  mp_jmpbuf_t* rsp_jb = exchanger->rsp_jb;
  exchanger->ctx_jb = NULL;
  exchanger->rsp_jb = NULL;
  void* rsp_jb_sp = rsp_jb->reg_sp;

  mp_jmpbuf_t my_jb;
  int a = 0;
  for (int i = 1; i <= size; i++) {
    int result;
    char* new_sp = dup_stack((char*)rsp_jb_sp);
    rsp_jb->reg_sp = (void*)new_sp;

    ret_val = i;
    exchanger->ctx_jb = &my_jb;
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
  intptr_t* env = (intptr_t*)xmalloc(sizeof(intptr_t));
  env[0] = n;

  exchanger_t* exchanger = (exchanger_t*)xmalloc(sizeof(exchanger_t));

  int out;

  mp_jmpbuf_t* my_jb = (mp_jmpbuf_t*)xmalloc(sizeof(mp_jmpbuf_t));
  exchanger->ctx_jb = my_jb;

  char* new_stack = get_stack();
  if (mp_setjmp(my_jb) == 0) {
    __asm__(
      "movq %0, %%rsp\n\t"
      :: "r"(new_stack)
      : "rsp" // have to clobber rsp because we use rsp addressing in &exchanger
    );
    body(fail, pick, env, exchanger);
    __builtin_unreachable();
  } else {
    out = ret_val;
  }
  
  free_stack(new_stack);

  return out;
}

int main(int argc, char *argv[]){
    init_stack_pool();
    int out = run(atoi(argv[1]));
    printf("%d\n", out);
    destroy_stack_pool();
    return 0;
}
