
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

intptr_t fib(intptr_t n) {
return (
({
intptr_t cond = n == 0;
cond ? 1 : ({
intptr_t cond = n == 1;
cond ? 1 : ({
intptr_t a = n - 1;
({
intptr_t b = n - 2;
({
intptr_t v1 = fib(a);
({
intptr_t v2 = fib(b);
v1 + v2;
});
});
});
});
});
})
);
}
int main() {
return (
(int)fib(5)
);
}
