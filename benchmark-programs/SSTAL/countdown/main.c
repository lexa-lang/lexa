#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

int get(intptr_t env[1]){
    int* a = (int*)env[0];
    return *a;
}

int set(intptr_t env[1], int n){
    int* a = (int*)env[0];
    *a = n;
    return 0;
}

int countdown(intptr_t handler_closure[3]){
    // Invoke get
    int n = ((int(*)(intptr_t*))handler_closure[0])((intptr_t*)handler_closure[2]);
    if(n == 0){
        return 0;
    } else {
        // Invoke set
        ((int(*)(intptr_t*, int))handler_closure[1])((intptr_t*)handler_closure[2], n-1);
        // Recurse
        return countdown(handler_closure);
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
    intptr_t closure[3] = {(intptr_t)&get, (intptr_t)&set, (intptr_t)env};

    // Run the handle body
    int out = countdown(closure);
    return out;
}

int main(int argc, char *argv[]){
    int out = run(atoi(argv[1]));
    printf("%d\n", out);
    return 0;
}