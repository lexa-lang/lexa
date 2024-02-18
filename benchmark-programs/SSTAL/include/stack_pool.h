#include <stdint.h>
#include <stdlib.h>
#include <immintrin.h>
#include <string.h>

#define STACK_SIZE (1024 * 8)
#define PREALLOCATED_STACKS 64
#define ALIGN_DOWN(ptr, alignment) ((intptr_t)(ptr) & ~((alignment) - 1))

static char* buffer;
static uint64_t bitmap;

void init_stack_pool() {
    buffer = (char*)aligned_alloc(STACK_SIZE, STACK_SIZE * PREALLOCATED_STACKS);
    bitmap = -1;
}

void destroy_stack_pool() {
    free(buffer);
    bitmap = 0;
}

__attribute__((noinline))
char* get_stack() {
    int index = __builtin_ffsll(bitmap);
    if (index == 0) {
        // Out of stack space
        exit(1);
        // return (char*)aligned_alloc(STACK_SIZE, STACK_SIZE);
    }
    index -= 1;
    bitmap &= ~(1 << index);
    return buffer + (index * STACK_SIZE) + STACK_SIZE;
}

__attribute__((noinline))
void free_stack(char* stack) {
    int index = ((intptr_t)stack - (intptr_t)buffer - 1) / STACK_SIZE;
    bitmap |= (1 << index);
}

// Does not work for an empty stack. But such situation should not happen.
__attribute__((noinline))
char* dup_stack(char* sp) {
    char* new_stack = get_stack();
    size_t num_bytes = STACK_SIZE - (intptr_t)sp % STACK_SIZE;
    char* new_sp = new_stack - num_bytes;
    memcpy(new_sp, sp, num_bytes);
    // avx2_memcpy_totally_aligned((void*)ALIGN_DOWN(new_sp, 32), (void*)ALIGN_DOWN(sp, 32), (num_bytes / 32 + 1) * 32);
    return new_sp;
}