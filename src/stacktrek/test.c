#include <assert.h>
#include "stack_pool.h"
#include "datastructure.h"

float epsilon = 1e-5;

int eq_floats(float a, float b) {
    return fabs(a - b) < epsilon;
}

int main() {
  init_stack_pool();

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

  int64_t f1 = boxFloat(1.1);
  int64_t f2 = boxFloat(0.1);
  assert(eq_floats(unboxFloat(floatAdd(f1, f2)), 1.2));
  assert(eq_floats(unboxFloat(floatSub(f1, f2)), 1.0));
  assert(eq_floats(unboxFloat(floatMul(f1, f2)), 0.11));
  assert(eq_floats(unboxFloat(floatDiv(f1, f2)), 11.0));
  return 0;
}