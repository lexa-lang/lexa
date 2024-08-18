#include <assert.h>
#include "datastructure.h"

float epsilon = 1e-5;

int eq_floats(float a, float b) {
    return fabs(a - b) < epsilon;
}

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

  int64_t f1 = I(1.1);
  int64_t f2 = I(0.1);
  assert(eq_floats(F(floatAdd(f1, f2)), 1.2));
  assert(eq_floats(F(floatSub(f1, f2)), 1.0));
  assert(eq_floats(F(floatMul(f1, f2)), 0.11));
  assert(eq_floats(F(floatDiv(f1, f2)), 11.0));
  return 0;
}