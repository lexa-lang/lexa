#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define STACK_SIZE 1024 * 1024

typedef struct {
  intptr_t fail;
  intptr_t pick;
  intptr_t env;
  intptr_t pc;
  intptr_t sp;
} closure_t;

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

void place(closure_t *handler_closure, int size) {
  for (int col = size; col >= 1; col--) {
    // Invoke pick
    // 1. Copy pc and sp
    intptr_t pc = handler_closure->pc;
    intptr_t sp = handler_closure->sp;
    // 2. Make resumption
    handler_closure->pc = (intptr_t)&&raise_cont;
    __asm__("movq %%rsp, %0" : "=g"(handler_closure->sp));
    // 3. Invoke pick

    __asm__ (
      "mov %1, %%rsp\n\t" // Move sp into rsp
      "mov %2, %%rdi\n\t" // Move size into rdi
      "mov %3, %%rsi\n\t" // Move col into rsi
      "jmp *%0\n\t" // Jump to the instruction address stored in ip
      : // No output operands
      : "r"(handler_closure[1]), "r"(handler_closure[4]), "r"(size), "r"(col) // abortive pc and sp, and size and col
      : "rdi", "rsi" // Clobbered registers
    );

raise_cont:
  }
}

int fail(intptr_t env[0]) {
  return 0;
}

int pick(intptr_t env[0], int size, intptr_t rsp[4]) {
  int a = 0;
  for (int i = 1; i <= size; i++) {
    intptr_t rsp_pc = rsp[2];
    intptr_t rsp_sp = rsp[3];
    char* rsp_sp_dup = dup_stack((char*)rsp_sp);
    // Restore handler's closure
    rsp[2] = (intptr_t)&&resume_cont;
    __asm__("movq %%rsp, %0" : "=r"(rsp[3]));
    // Resume the resumption
    __asm__ volatile (
      "mov %1, %%rsp\n\t" // Move sp into rsp
      "mov %3, %%eax\n\t" // Move i into eax
      "jmp *%0\n\t" // Jump to the instruction address stored in ip
      : // No output operands
      : "g"(rsp_pc), "g"(rsp_sp), "g"(i) // abortive pc and sp, and i
    );

resume_cont:
    int result;
    __asm__("movl %%eax, %0" : "=r"(result));
    // Restore resumption
    rsp[2] = rsp_pc;
    rsp[3] = rsp_sp_dup;
    a += result;
  }

  return a;
}

int run(int n){
  // Stack-allocate the closure for the handler
  // 1. allocate the environment
  intptr_t env[0] = {};
  // 2. allocate the closure
  closure_t closure[5] = {(intptr_t)&fail, (intptr_t)&pick, (intptr_t)env, (intptr_t)&&handle_cont, (intptr_t)NULL};
  int out;
  // 3. fill in the abortive stack pointer
  __asm__("movq %%rsp, %0" : "=r"(closure->sp));

  // Run the handle body


handle_cont:
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
