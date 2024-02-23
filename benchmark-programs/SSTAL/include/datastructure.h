#include <stdlib.h>
#include <longjmp.h>
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

node_t* listNode(int64_t value, node_t* next) {
  node_t* new_node = (node_t*)xmalloc(sizeof(node_t));
  new_node->value = value;
  new_node->next = next;
  return new_node;
}

node_t* listEnd() {
  return NULL;
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

tree_t* treeLeaf() {
  return NULL;
}

bool treeIsLeaf(tree_t* t) {
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