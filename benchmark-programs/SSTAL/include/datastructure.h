#include <stdlib.h>
#include <stdbool.h>

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

node_t* listNode(int64_t value, node_t* next) {
  node_t* new_node = (node_t*)xmalloc(sizeof(node_t));
  new_node->value = value;
  new_node->next = next;
  return new_node;
}

node_t* listEnd() {
  return NULL;
}

bool listIsEmpty(node_t* xs) {
  return xs == NULL;
}

int64_t listHead(node_t* xs) {
  return xs->value;
}

node_t* listTail(node_t* xs) {
  return xs->next;
}

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

tree_t* treeNode(int64_t value, tree_t* left, tree_t* right) {
  tree_t* new_node = (tree_t*)xmalloc(sizeof(tree_t));
  new_node->value = value;
  new_node->left = left;
  new_node->right = right;
  return new_node;
}

tree_t* treeLeaf() {
  return NULL;
}

bool treeIsEmpty(tree_t* t) {
  return t == NULL;
}

tree_t* treeLeft(tree_t* t) {
  return t->left;
}

tree_t* treeRight(tree_t* t) {
  return t->right;
}

int64_t treeValue(tree_t* t) {
  return t->value;
}

queue_t* queueMake() {
  queue_t* q = (queue_t*)xmalloc(sizeof(queue_t));
  q->front = NULL;
  q->rear = NULL;
  return q;
}

bool queueIsEmpty(queue_t* q) {
  return q->front == NULL;
}

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

int64_t queueDeq(queue_t* q) {
  int64_t value = q->front->value;
  node_t* old_front = q->front;
  q->front = q->front->next;
  free(old_front);
  return value;
}

int64_t queueLen(queue_t* q) {
  int64_t len = 0;
  node_t* current = q->front;
  while (current != NULL) {
    len++;
    current = current->next;
  }
  return len;
}
