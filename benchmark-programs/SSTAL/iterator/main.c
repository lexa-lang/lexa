#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

int emit(intptr_t env[1], int n){
    int* a = (int*)env[0];
    *a += n;
    return 0;
}

void range(intptr_t handler_closure[3], int n){
  for (int i = 0; i < n; i++){
    ((int(*)(intptr_t*, int))handler_closure[0])((intptr_t*)handler_closure[1], i);
  }
}

int run(int n){
    // Heap-allocate a reference cell
    int* a = (int*)malloc(1 * sizeof(int));
    *a = n;

    // Stack-allocate the closure for the handler
    // 1. allocate the environment
    intptr_t env[1] = {(intptr_t)a};
    // 2. allocate the closure
    intptr_t closure[2] = {(intptr_t)&emit, (intptr_t)env};

    // Run the handle body
    range(closure, n);
    return *a;
}

int main(int argc, char *argv[]){
    int out = run(atoi(argv[1]));
    printf("%d\n", out);
    return 0;
}