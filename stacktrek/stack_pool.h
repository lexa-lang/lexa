#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <common.h>
#include <datastructure.h>

#define STACK_SIZE (1024LL * 8)

// #define USE_LIST
#ifdef USE_LIST

static node_t* cache = NULL;

void init_stack_pool() {
}

void destroy_stack_pool() {
}

char* get_stack() {
    if (cache) {
        intptr_t stack = cache->value;
        cache = cache->next;
        return (char*)stack + STACK_SIZE;
    } else {
        char* stack = (char*)aligned_alloc(STACK_SIZE, STACK_SIZE);
        return stack + STACK_SIZE;
    }
}

void free_stack(char* stack) {
    stack = (char*)(((intptr_t)stack - 1) / STACK_SIZE * STACK_SIZE);
    node_t* node = listNode((intptr_t)stack, cache);
    cache = node;
}

void free_stack_on_abort(char* curr_stack, char* target_stack) {
    if ((char*)0x7fffff7ff000 <= curr_stack && curr_stack < (char*)0x7fffffffffff) {
        // We are currently on the main stack, no need to free
        return;
    }
    if (((intptr_t)curr_stack - 1) / STACK_SIZE == ((intptr_t)target_stack - 1) / STACK_SIZE) {
        // Going to the same stack, no need to free
        return;
    }
    free_stack(curr_stack);
}

// Does not work for an empty stack. But such situation should not happen.
char* dup_stack(char* sp) {
    char* new_stack = get_stack();
    size_t num_bytes = STACK_SIZE - (intptr_t)sp % STACK_SIZE;
    char* new_sp = new_stack - num_bytes;
    memcpy(new_sp, sp, num_bytes);
    return new_sp;
}
#else
#define PREALLOCATED_STACKS 64

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

// HACK! TODO: scheduler_ocaml needs the following attribute for correctness
__attribute__((noinline))
char* get_stack() {
    if (!buffer) {
        init_stack_pool();
    }
    int index = __builtin_ffsll(bitmap);
    if (index == 0) {
        char* out = (char*)aligned_alloc(STACK_SIZE, STACK_SIZE);
        return out + STACK_SIZE;
    }
    index -= 1;
    bitmap &= ~(1ULL << index);
    return buffer + (index * STACK_SIZE) + STACK_SIZE;
}

void free_stack(char* stack) {
    if (stack >= buffer && stack < buffer + (STACK_SIZE * PREALLOCATED_STACKS)) {
        int index = ((intptr_t)stack - 1 - (intptr_t)buffer) / STACK_SIZE;
        bitmap |= (1LL << index);
    } else {
        // NB: why -1? Think what should happen when an empty stack is freeed.
        // Because an empty stack is +STACK_SIZE from the beginning of the buffer,
        // If we don't -1, the stack pointer will be pointing to the start of the next stack.
        char* stack_start = (char*)(((intptr_t)stack - 1) / STACK_SIZE * STACK_SIZE);
        free(stack_start);
    }
}

void free_stack_on_abort(char* curr_stack, char* target_stack) {
    if ((char*)0x7fffff7ff000 <= curr_stack && curr_stack < (char*)0x7fffffffffff) {
        // We are currently on the main stack, no need to free
        return;
    }
    if (((intptr_t)curr_stack - 1) / STACK_SIZE == ((intptr_t)target_stack - 1) / STACK_SIZE) {
        // Going to the same stack, no need to free
        return;
    }
    free_stack(curr_stack);
}

// Does not work for an empty stack. But such situation should not happen.
char* dup_stack(char* sp) {
    char* new_stack = get_stack();
    size_t num_bytes = STACK_SIZE - (intptr_t)sp % STACK_SIZE;
    char* new_sp = new_stack - num_bytes;
    memcpy(new_sp, sp, num_bytes);
    return new_sp;
}
#endif