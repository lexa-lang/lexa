#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <common.h>
#include <string.h>
#include <stdio.h>
#include <assert.h>

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


DEBUG_ATTRIBUTE
node_t* listNode(int64_t value, node_t* next) {
  node_t* new_node = (node_t*)xmalloc(sizeof(node_t));
  new_node->value = value;
  new_node->next = next;
  return new_node;
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
node_t* listTail(node_t* xs) {
  return xs->next;
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
  free(old_front);
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

DEBUG_ATTRIBUTE
// Since it's not allowed to cast float to integer,
// we do the cast inside the function using memcpy.
// To outside, the value is of type int.
int64_t floatMake(int64_t divideng, int64_t divisor) {
  double q = (double)divideng / (double)divisor;
  int64_t result;
  memcpy(&result, &q, sizeof(int64_t));
  return result;
}

DEBUG_ATTRIBUTE
int64_t floatAdd(int64_t a, int64_t b) {
  double x, y;
  memcpy(&x, &a, sizeof(int64_t));
  memcpy(&y, &b, sizeof(int64_t));
  double z = x + y;
  int64_t result;
  memcpy(&result, &z, sizeof(int64_t));
  return result;
}

DEBUG_ATTRIBUTE
int64_t floatMul(int64_t a, int64_t b) {
  double x, y;
  memcpy(&x, &a, sizeof(int64_t));
  memcpy(&y, &b, sizeof(int64_t));
  double z = x * y;
  int64_t result;
  memcpy(&result, &z, sizeof(int64_t));
  return result;
}

DEBUG_ATTRIBUTE
int64_t floatPrint(int64_t x) {
  double f;
  memcpy(&f, &x, sizeof(int64_t));
  printf("%f\n", f);
  return 0;
}