#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <setjmp.h>

typedef struct {
  intptr_t done;
  intptr_t* env;
  jmp_buf* jb;
} closure_t;

typedef struct node {
    int value;
    struct node* next;
} node;

intptr_t jmp_arg;

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
      jmp_arg = 0;
      longjmp(*handler_closure->jb, 1);
      __builtin_unreachable();
    } else {
      // Recurse
      return lst->value * product(handler_closure, lst->next);
    }
  }
}

void body(closure_t *handler_closure) {
  int out = product(handler_closure, (node*)handler_closure->env[0]);
  jmp_arg = out;
  longjmp(*handler_closure->jb, 1);
  __builtin_unreachable();
}

int runProduct(node* lst) {
  // Stack-allocate the closure for the handler
  // 1. allocate the environment
  intptr_t env[1] = {(intptr_t)lst};
  // 2. allocate the closure
  jmp_buf jb;
  closure_t closure = {(intptr_t)&done, env, &jb};
  int out;
  if (setjmp(*closure.jb) == 0) {
    body(&closure);
    __builtin_unreachable();
  } else {
    out = jmp_arg;
  }

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