#include <stdio.h>
#include <stdlib.h>

// A simple Fibonacci function
unsigned long long fib(int n) {
    if (n <= 1) return n;
    return fib(n - 1) + fib(n - 2);
}

int main() {
    const size_t stackSize = 1024 * 1024; // 1MB stack size
    unsigned char* newStack = (unsigned char*)malloc(stackSize) + stackSize; // Allocate new stack space and adjust to the end (stack grows downwards on x86)
    unsigned char* oldStack;

    if (!newStack) {
        printf("Failed to allocate memory for the new stack.\n");
        return 1;
    }

    // Store the current stack pointer
    __asm__ volatile("movq %%rsp, %0" : "=g" (oldStack));

    // Swap to the new stack
    __asm__ volatile("movq %0, %%rsp" :: "g" (newStack));

    // Now the new stack is in use, call the Fibonacci function
    int n = 10; // Example: Compute the 10th Fibonacci number
    int result = fib(n);
    printf("Fibonacci(%d) = %llu\n", n, result);

    // Restore the original stack pointer
    __asm__ volatile("movq %0, %%rsp" :: "g" (oldStack));

    free(newStack - stackSize); // Adjust the pointer back before freeing

    return 0;
}
