#include <stdint.h>
#include <stdlib.h>
#include <immintrin.h>
#include <string.h>
#include <assert.h>

#define STACK_SIZE (1024 * 8)
#define PREALLOCATED_STACKS 64
#define ALIGN_DOWN(ptr, alignment) ((intptr_t)(ptr) & ~((alignment) - 1))

static char* buffer = 0;
static uint64_t bitmap;

void init_stack_pool() {
    buffer = (char*)aligned_alloc(STACK_SIZE, STACK_SIZE * PREALLOCATED_STACKS);
    bitmap = -1;
}

void destroy_stack_pool() {
    free(buffer);
    bitmap = 0;
}

char* get_stack() {
    assert(buffer);
    int index = __builtin_ffsll(bitmap);
    if (index == 0) {
        // Out of stack space
        return (char*)aligned_alloc(STACK_SIZE, STACK_SIZE);
    }
    index -= 1;
    bitmap &= ~(1ULL << index);
    return buffer + (index * STACK_SIZE) + STACK_SIZE;
}

void free_stack(char* stack) {
    if (stack >= buffer && stack < buffer + (STACK_SIZE * PREALLOCATED_STACKS)) {
        int index = ((intptr_t)stack - 1 - (intptr_t)buffer) / STACK_SIZE;
        bitmap |= (1 << index);
    } else {
        // NB: why -1? Think what should happen when an empty stack is freeed.
        // Because an empty stack is +STACK_SIZE from the beginning of the buffer,
        // If we don't -1, the stack pointer will be pointing to the start of the next stack.
        free((void*)(((intptr_t)stack - 1) / STACK_SIZE * STACK_SIZE));
    }
}

// Does not work for an empty stack. But such situation should not happen.
char* dup_stack(char* sp) {
    char* new_stack = get_stack();
    size_t num_bytes = STACK_SIZE - (intptr_t)sp % STACK_SIZE;
    char* new_sp = new_stack - num_bytes;
    memcpy(new_sp, sp, num_bytes);
    return new_sp;
}