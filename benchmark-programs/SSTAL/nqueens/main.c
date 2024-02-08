#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define STACK_SIZE 1024 * 1024

typedef struct node {
    int value;
    struct node* next;
} node;

typedef struct {
  intptr_t fail;
  intptr_t pick;
} sig_t;

typedef struct {
  sig_t *funcs;
  intptr_t env;
  intptr_t sp;
} closure_t;

typedef struct {
  intptr_t _unused1;
  intptr_t _unused2;
  intptr_t sp;
} resumption_t;

char* dup_stack(char* sp) {
    char* new_stack = (char*)aligned_alloc(STACK_SIZE, STACK_SIZE);
    if (!new_stack) {
        fprintf(stderr, "Failed to allocate memory for the new stack.\n");
        exit(EXIT_FAILURE);
    }
    char* new_sp = new_stack + STACK_SIZE;
    size_t num_bytes = STACK_SIZE - (intptr_t)sp % STACK_SIZE;
    memcpy(new_sp - num_bytes, sp - num_bytes, num_bytes);
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

node* place(closure_t *handler_closure, int size, int column) {
  if (column == 0) {
    return NULL;
  } else {
    node* rest = place(handler_closure, size, column - 1);
    int next;
    // Invoke pick
    intptr_t sp = handler_closure->sp;
    __asm__ (
      // Prepare raise's continuation
      "addq $-128, %%rsp\n\t"
      "pushq %1\n\t"
      "movq %%rsp, %0\n\t"
      // Swap stack and invoke handler
      "movq %2, %%rsp\n\t"
      "jmp *%3\n\t"
      : "=g"(handler_closure->sp)
      : "r"(&&raise_cont), "r"(sp), "r"(handler_closure->funcs->pick),
        "D"(handler_closure->env), "S"(size), "d"(handler_closure)
    );

raise_cont:
    __asm__(
      "sub $-128, %%rsp\n\t"
      "movl %%eax, %0\n\t"
      : "=r"(next)
    );
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
      __asm__ (
        "mov %2, %%rsp\n\t"
        "jmp *%1\n\t"
        : // No output operands
        : "D"(handler_closure->env), "r"(handler_closure->funcs->fail), "r"(handler_closure->sp)
      );
      __builtin_unreachable();
    }
  }
}

int body(closure_t *handler_closure, int size, int column) {
  place(handler_closure, size, column);
  __asm__ (
    "mov %0, %%rsp\n\t"
    "ret\n\t"
    : // No output operands
    : "r"(handler_closure->sp)
  );
  __builtin_unreachable();
}

int fail(intptr_t env[0]) {
  return 0;
}

int pick(intptr_t env[0], int size, resumption_t *rsp) {
  int a = 0;
  for (int i = 1; i <= size; i++) {
    intptr_t rsp_sp = rsp->sp;
    char* rsp_sp_dup = dup_stack((char*)rsp_sp);
    int result;
    // Resume the resumption
    __asm__ (
      // Prepare the resume's continuation
      "addq $-128, %%rsp\n\t"
      "pushq %3\n\t"
      "movq %%rsp, %0\n\t"
      // Swap stack and invoke resumption's return function
      "mov %2, %%rsp\n\t"
      "ret\n\t"
      : "=g"(rsp->sp)
      : "a"(i), "r"(rsp_sp), "r"(&&resume_cont)
    );

resume_cont:
    __asm__(
      "sub $-128, %%rsp\n\t"
      "movl %%eax, %0\n\t"
      : "=r"(result)
    );
    rsp->sp = (intptr_t)rsp_sp_dup;
    a += result;
  }

  return a;
}

int run(int n){
  // Stack-allocate the closure for the handler
  // 1. allocate the environment
  intptr_t env[0] = {};
  // 2. allocate the closure
  sig_t funcs = {(intptr_t)&fail, (intptr_t)&pick};
  closure_t closure = {&funcs, (intptr_t)env, (intptr_t)NULL};
  int out;
  // 3. allocate a new stack
  char* new_stack = (char*)aligned_alloc(STACK_SIZE, STACK_SIZE);
  if (!new_stack) {
    fprintf(stderr, "Failed to allocate memory for the new stack.\n");
    exit(EXIT_FAILURE);
  }
  char* new_sp = new_stack + STACK_SIZE;
  __asm__(
    // Prepare handle's continuation
    "addq $-128, %%rsp\n\t"
    "pushq %4\n\t"                     // Push return address onto the stack
    "movq %%rsp, %0\n\t"                 // Move sp into closure
    // Swap stack and run the body
    "movq %5, %%rsp\n\t"
    "jmp body\n\t"
    : "=g"(closure.sp)
    : "D"(&closure), "S"(n), "d"(n), "a"(&&handle_cont), "c"(new_sp)
    : "r8", "r9", "r10", "r11", "r12", "r13", "r14", "r15", "rbx", "rbp", "rsp"
  );

handle_cont:
  __asm__(
    "sub $-128, %%rsp\n\t"
    "movl %%eax, %0\n\t"                 // Move the result to the output variable"
    : "=r"(out)
  );

  return out;
}

int main(int argc, char *argv[]){
    int out = run(atoi(argv[1]));
    printf("%d\n", out);
    return 0;
}
