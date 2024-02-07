#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

typedef struct {
  intptr_t done;
  intptr_t env;
  intptr_t sp;
} closure_t;

typedef struct node {
    int value;
    struct node* next;
} node;

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

int done(intptr_t env[0], int r) {
  return r;
}

int product(closure_t *handler_closure, node* lst) {
  if (lst == NULL) {
    return 1;
  } else {
    if (lst->value == 0) {
      // Invoke the handler
      __asm__ volatile (
        "mov %2, %%rsp\n\t" // Move sp into rsp
        "xor %%rsi, %%rsi\n\t" // Move 0 into rsi
        "jmp *%1\n\t" // Jump to the instruction address stored in ip
        : // No output operands
        : "D"(handler_closure->env), "r"(handler_closure->done), "r"(handler_closure->sp)
        : // NO need to list any clobbered registers as we are not coming back
      );
    } else {
      // Recurse
      return lst->value * product(handler_closure, lst->next);
    }
  }
}

int runProduct(node* lst) {
  // Stack-allocate the closure for the handler
  // 1. allocate the environment
  intptr_t env[0] = {};
  // 2. allocate the closure
  closure_t closure = {(intptr_t)&done, (intptr_t)env, (intptr_t)NULL};
  int out;
  // 3. fill in the abortive stack pointer
  __asm__(
    "addq $-128, %%rsp\n\t"
    "pushq %3\n\t"                     // Push return address onto the stack
    "movq %%rsp, %0\n\t"                 // Move sp into closure
    "jmp product\n\t"
    : "=g"(closure.sp)
    : "D"(&closure), "S"(lst), "a"(&&handle_cont)
    : "rcx", "rdx", "r8", "r9", "r10", "r11", "r12", "r13", "r14", "r15", "rbx", "rbp", "rsp"
  );
handle_cont:
  __asm__(
    "sub $-128, %%rsp\n\t"
    "movl %%eax, %0\n\t"                 // Move the result to the output variable"
    : "=r"(out)
  );

  return out;
}

int run(int n){
  int a = 0;
  node* lst = enumerate(1000);
  for (int i = 0; i < n; i++) {
    a += runProduct(lst);
  }
  return a;
}

int main(int argc, char *argv[]){
    int out = run(atoi(argv[1]));
    printf("%d\n", out);
    return 0;
}