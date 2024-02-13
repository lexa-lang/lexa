#include <stdint.h>
#include <stdlib.h>
#include <immintrin.h>
#include <string.h>

#define STACK_SIZE (1024 * 8)
#define PREALLOCATED_STACKS 64
#define ALIGN_DOWN(ptr, alignment) ((intptr_t)(ptr) & ~((alignment) - 1))

static char* buffer;
static u_int64_t bitmap;

void init_stack_pool() {
    buffer = (char*)aligned_alloc(STACK_SIZE, STACK_SIZE * PREALLOCATED_STACKS);
    bitmap = -1;
}

void destroy_stack_pool() {
    free(buffer);
    bitmap = 0;
}

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

void free_stack(char* stack) {
    int index = ((intptr_t)stack - (intptr_t)buffer - 1) / STACK_SIZE;
    bitmap |= (1 << index);
    // if (stack >= buffer && stack < buffer + (STACK_SIZE * PREALLOCATED_STACKS)) {
    //     int index = ((intptr_t)stack - (intptr_t)buffer) / STACK_SIZE;
    //     bitmap |= (1 << index);
    // } else {
    //     // NB: why -1? Think what should happen when an empty stack is freeed.
    //     // Because an empty stack is +STACK_SIZE from the beginning of the buffer,
    //     // If we don't -1, the stack pointer will be pointing to the start of the next stack.
    //     free((void*)(((intptr_t)stack - 1) / STACK_SIZE * STACK_SIZE));
    // }
}

void avx2_memcpy_totally_aligned(void* dest, const void* src, size_t len) {
    // Cast to appropriate pointer types for alignment
    char* dst8 = (char*)dest;
    const char* src8 = (char*)src;

    // Calculate how many 256-bit chunks we can copy directly
    size_t avx2_chunks = len / 32;

    // AVX2 Copy Loop: Process 32 bytes (256 bits) at a time
    for (size_t i = 0; i < avx2_chunks; ++i) {
        __m256i ymm_data = _mm256_load_si256((const __m256i*)(src8 + i * 32));
        _mm256_store_si256((__m256i*)(dst8 + i * 32), ymm_data);
    }

    // Tail Copy: Handle remaining bytes (less than 32)
    // size_t tail = len % 32;
    // for (size_t i = 0; i < tail; ++i) {
    //     dst8[avx2_chunks * 32 + i] = src8[avx2_chunks * 32 + i];
    // }
}

// Does not work for an empty stack. But such situation should not happen.
char* dup_stack(char* sp) {
    char* new_stack = get_stack();
    size_t num_bytes = STACK_SIZE - (intptr_t)sp % STACK_SIZE;
    char* new_sp = new_stack - num_bytes;
    // memcpy(new_sp, sp, num_bytes);
    avx2_memcpy_totally_aligned((void*)ALIGN_DOWN(new_sp, 32), (void*)ALIGN_DOWN(sp, 32), (num_bytes / 32 + 1) * 32);
    return new_sp;
}