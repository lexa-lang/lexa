#include <assert.h>
#include "datastructure.h"

int main() {
  queue_t* q = queueMake();
  assert(queueIsEmpty(q));
  queueEnq(q, 1);
  assert(!queueIsEmpty(q));
  queueEnq(q, 2);
  assert(queueDeq(q) == 1);
  queueEnq(q, 3);
  assert(queueDeq(q) == 2);
  assert(queueDeq(q) == 3);
  queueEnq(q, 4);
  assert(queueDeq(q) == 4);
  assert(queueIsEmpty(q));
  free(q);
  return 0;
}