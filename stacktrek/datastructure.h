#pragma once

#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <common.h>
#include <string.h>
#include <stdio.h>
#include <assert.h>
#include <math.h>
#include "gc.h"

#define malloc(n) GC_malloc(n)
#define realloc(obj, size) GC_realloc(obj, size)
#define xmalloc(size) ({                \
    void *_ptr = malloc(size);          \
    if (_ptr == NULL) {                 \
        exit(EXIT_FAILURE);             \
    }                                   \
    _ptr;                               \
})

typedef struct node_t {
    int64_t value;
    struct node_t* next;
} node_t;

typedef struct tree_t {
    int64_t value;
    struct tree_t* left;
    struct tree_t* right;
} tree_t;

typedef struct queue_t {
    node_t* front;
    node_t* rear;
} queue_t;

typedef struct array_t {
    int64_t* data;
    int64_t size;
    int64_t capacity;
} array_t;

#define readInt() (argc == 2) ? atoi(argv[1]) : (printf("Usage: %s <int>\n", argv[0]), exit(EXIT_FAILURE), 0)

DEBUG_ATTRIBUTE
int64_t printInt(int64_t x) {
  printf("%ld\n", x);
  return 0;
}

DEBUG_ATTRIBUTE
int64_t printChar(int64_t x) {
  printf("%c\n", (char)x);
  return 0;
}


DEBUG_ATTRIBUTE
node_t* listNode(int64_t value, node_t* next) {
  node_t* new_node = (node_t*)xmalloc(sizeof(node_t));
  new_node->value = value;
  new_node->next = next;
  return new_node;
}

DEBUG_ATTRIBUTE
node_t* listRange(int64_t start, int64_t end) {
  if (start > end) {
    return NULL;
  } else {
    return listNode(start, listRange(start + 1, end));
  }
}

DEBUG_ATTRIBUTE
node_t* listPrint(node_t* xs) {
  while (xs != NULL) {
    printf("%ld ", xs->value);
    xs = xs->next;
  }
  printf("\n");
  return NULL;
}

DEBUG_ATTRIBUTE
node_t* listEnd() {
  return NULL;
}

DEBUG_ATTRIBUTE
bool listIsEmpty(node_t* xs) {
  return xs == NULL;
}

DEBUG_ATTRIBUTE
int64_t listHead(node_t* xs) {
  return xs->value;
}

DEBUG_ATTRIBUTE
int64_t listSetHead(node_t* xs, int64_t value) {
  xs->value = value;
  return value;
}

DEBUG_ATTRIBUTE
node_t* listTail(node_t* xs) {
  return xs->next;
}

DEBUG_ATTRIBUTE
int64_t listSetTail(node_t* xs, node_t* new_tail) {
  xs->next = new_tail;
  return 0;
}

DEBUG_ATTRIBUTE
node_t* listAppend(node_t* xs1, node_t* xs2) {
  if (xs1 == NULL) {
    return xs2;
  } else {
    node_t* new_node = (node_t*)xmalloc(sizeof(node_t));
    new_node->value = xs1->value;
    new_node->next = listAppend(xs1->next, xs2);
    return new_node;
  }
}

DEBUG_ATTRIBUTE
int64_t listMax(node_t* xs) {
  int64_t m = 0;
  while (xs != NULL) {
    if (xs->value > m) {
      m = xs->value;
    }
    xs = xs->next;
  }
  return m;
}

DEBUG_ATTRIBUTE
int64_t listLen(node_t* xs) {
  int64_t len = 0;
  while (xs != NULL) {
    len++;
    xs = xs->next;
  }
  return len;
}

DEBUG_ATTRIBUTE
int64_t listAt(node_t* xs, int64_t i) {
  #ifdef DEBUG
  assert(0 <= i && i < listLen(xs));
  #endif

  while (i > 0) {
    xs = xs->next;
    i--;
  }
  return xs->value;
}

DEBUG_ATTRIBUTE
tree_t* treeNode(int64_t value, tree_t* left, tree_t* right) {
  tree_t* new_node = (tree_t*)xmalloc(sizeof(tree_t));
  new_node->value = value;
  new_node->left = left;
  new_node->right = right;
  return new_node;
}

DEBUG_ATTRIBUTE
tree_t* treeLeaf() {
  return NULL;
}

DEBUG_ATTRIBUTE
bool treeIsEmpty(tree_t* t) {
  return t == NULL;
}

DEBUG_ATTRIBUTE
tree_t* treeLeft(tree_t* t) {
  return t->left;
}

DEBUG_ATTRIBUTE
tree_t* treeRight(tree_t* t) {
  return t->right;
}

DEBUG_ATTRIBUTE
int64_t treeValue(tree_t* t) {
  return t->value;
}

DEBUG_ATTRIBUTE
queue_t* queueMake() {
  queue_t* q = (queue_t*)xmalloc(sizeof(queue_t));
  q->front = NULL;
  q->rear = NULL;
  return q;
}

DEBUG_ATTRIBUTE
bool queueIsEmpty(queue_t* q) {
  return q->front == NULL;
}

DEBUG_ATTRIBUTE
int64_t queueEnq(queue_t* q, int64_t value) {
  node_t* new_node = listNode(value, NULL);
  if (q->front == NULL) {
    q->front = new_node;
  } else {
    q->rear->next = new_node;
  }
  q->rear = new_node;
  return value;
}

DEBUG_ATTRIBUTE
int64_t queueDeq(queue_t* q) {
  int64_t value = q->front->value;
  node_t* old_front = q->front;
  q->front = q->front->next;
  // free(old_front);
  return value;
}

DEBUG_ATTRIBUTE
int64_t queueLen(queue_t* q) {
  int64_t len = 0;
  node_t* current = q->front;
  while (current != NULL) {
    len++;
    current = current->next;
  }
  return len;
}

DEBUG_ATTRIBUTE
char* stringMake(char c, int64_t n) {
  char* s = (char*)xmalloc(n + 1);
  for (int64_t i = 0; i < n; i++) {
    s[i] = c;
  }
  s[n] = '\0';
  return s;
}

DEBUG_ATTRIBUTE
int64_t stringLen(char* s) {
  int64_t len = 0;
  while (s[len] != '\0') {
    len++;
  }
  return len;
}

char* emptyString = "\0";

char* stringSubStr(char* s, int64_t startpos, int64_t endpos) {
  if (endpos <= startpos) {
    return emptyString;
  }
  int64_t n = endpos - startpos;
  char* sub = (char*)xmalloc(n + 1);
  for (int64_t i = 0; i < n; i++) {
    sub[i] = s[startpos + i];
  }
  sub[n] = '\0';
  return sub;
}

DEBUG_ATTRIBUTE
int64_t stringCharAt(char* s, int64_t pos) {
  return s[pos];
}

#define I(x) ((union { double d; int64_t i; }){ .d = x }).i
#define F(x) ((union { double d; int64_t i; }){ .i = x }).d

DEBUG_ATTRIBUTE
int64_t printFloat(int64_t x) {
  printf("%f\n", F(x));
  return 0;
}

DEBUG_ATTRIBUTE
int64_t floatAdd(int64_t a, int64_t b) {
  return I(F(a) + F(b));
}

DEBUG_ATTRIBUTE
int64_t floatSub(int64_t a, int64_t b) {
  return I(F(a) - F(b));
}

DEBUG_ATTRIBUTE
int64_t floatMul(int64_t a, int64_t b) {
  return I(F(a) * F(b));
}

DEBUG_ATTRIBUTE
int64_t floatDiv(int64_t a, int64_t b) {
  return I(F(a) / F(b));
}

DEBUG_ATTRIBUTE
int64_t floatNeg(int64_t a) {
  return I(-F(a));
}

DEBUG_ATTRIBUTE
int64_t floatRand() {
  return I((double)rand() / RAND_MAX);
}

DEBUG_ATTRIBUTE
int64_t floatPi() {
  return I(M_PI);
}

DEBUG_ATTRIBUTE
int64_t floatCos(int64_t x) {
  return I(cos(F(x)));
}

DEBUG_ATTRIBUTE
int64_t floatSin(int64_t x) {
  return I(sin(F(x)));
}

DEBUG_ATTRIBUTE
int64_t floatSqrt(int64_t x) {
  return I(sqrt(F(x)));
}

DEBUG_ATTRIBUTE
int64_t floatLog(int64_t x) {
  return I(log(F(x)));
}

DEBUG_ATTRIBUTE
int64_t floatLt(int64_t a, int64_t b) {
  return F(a) < F(b);
}

DEBUG_ATTRIBUTE
int64_t boolAnd(int64_t a, int64_t b) {
  return a && b;
}

DEBUG_ATTRIBUTE
int64_t boolOr(int64_t a, int64_t b) {
  return a || b;
}

DEBUG_ATTRIBUTE
array_t* arrayMake(int64_t size) {
  array_t* a = (array_t*)xmalloc(sizeof(array_t));
  a->data = (int64_t*)xmalloc(size * sizeof(int64_t));
  a->size = size;
  a->capacity = size;
  return a;
}

DEBUG_ATTRIBUTE
array_t* arrayMakeInit(int64_t size, int64_t init) {
  array_t* a = (array_t*)xmalloc(sizeof(array_t));
  a->data = (int64_t*)xmalloc(size * sizeof(int64_t));
  a->size = size;
  a->capacity = size;
  for (int64_t i = 0; i < size; i++) {
    a->data[i] = init;
  }
  return a;
}

DEBUG_ATTRIBUTE
int64_t arrayLen(array_t* a) {
  return a->size;
}

DEBUG_ATTRIBUTE
int64_t arrayAt(array_t* a, int64_t i) {
  #ifdef DEBUG
  assert(0 <= i && i < a->size);
  #endif

  return a->data[i];
}

DEBUG_ATTRIBUTE
int64_t arraySet(array_t* a, int64_t i, int64_t value) {
  #ifdef DEBUG
  assert(0 <= i && i < a->size);
  #endif

  a->data[i] = value;
  return value;
}

DEBUG_ATTRIBUTE
int64_t arrayPush(array_t* a, int64_t value) {
  if (a->size == a->capacity) {
    a->capacity = a->capacity * 2 + 1;
    a->data = (int64_t*)realloc(a->data, a->capacity * sizeof(int64_t));
  }
  a->data[a->size] = value;
  a->size++;
  return value;
}

DEBUG_ATTRIBUTE
int64_t arrayPop(array_t* a) {
  #ifdef DEBUG
  assert(a->size > 0);
  #endif

  a->size--;
  return a->data[a->size];
}

DEBUG_ATTRIBUTE
int64_t arrayPrint(array_t* a) {
  for (int64_t i = 0; i < a->size; i++) {
    printf("%ld ", a->data[i]);
  }
  printf("\n");
  return 0;
}

DEBUG_ATTRIBUTE
int64_t arrayPrintChars(array_t* a) {
  for (int64_t i = 0; i < a->size; i++) {
    printf("%c", (char)a->data[i]);
  }
  printf("\n");
  return 0;
}

DEBUG_ATTRIBUTE
int64_t pairMake(int32_t a, int32_t b) {
  return ((int64_t)a << 32) | (int64_t)b;
}

DEBUG_ATTRIBUTE
int32_t pairFst(int64_t p) {
  return (int32_t)(p >> 32);
}

DEBUG_ATTRIBUTE
int32_t pairSnd(int64_t p) {
  return (int32_t)p;
}