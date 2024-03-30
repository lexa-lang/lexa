#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <defs.h>
#include <datastructure.h>


intptr_t product(intptr_t xs, intptr_t abort_stub) {
return(({
intptr_t cond = listIsEmpty((node_t*)xs);
(cond) ? (0) : (({
intptr_t y = listHead((node_t*)xs);
({
intptr_t ys = listTail((node_t*)xs);
({
intptr_t cond = y == 0;
(cond) ? (RAISE(((meta_t*)abort_stub), 0, (0))) : (({
intptr_t p = product(ys,abort_stub);
y * p;
}));
});
});
}));
}));
}

intptr_t enumerate(intptr_t i) {
return(({
intptr_t cond = i < 0;
(cond) ? (listEnd()) : (({
intptr_t arg1 = i - 1;
({
intptr_t arg2 = enumerate(arg1);
listNode((int64_t)i, (node_t*)arg2);
});
}));
}));
}

intptr_t done(intptr_t* env, intptr_t r, void** exc) {
return(r);
}
intptr_t body(intptr_t abort_stub) {
return(({
intptr_t arg1 = ((intptr_t*)((meta_t*)abort_stub)->env)[0];
product(arg1,abort_stub);
}));
}

intptr_t runProduct(intptr_t xs) {
return(HANDLE(body, ({ABORT, done}), (xs)));
}

intptr_t loop(intptr_t xs, intptr_t i, intptr_t a) {
return(({
intptr_t cond = i == 0;
(cond) ? (a) : (({
intptr_t arg1 = i - 1;
({
intptr_t arg2 = runProduct(xs);
({
intptr_t arg3 = a + arg2;
loop(xs,arg1,arg3);
});
});
}));
}));
}

intptr_t run(intptr_t n) {
return(({
intptr_t xs = enumerate(1000);
loop(xs,n,0);
}));
}

int main(int argc, char *argv[]) {
return((int)({
intptr_t arg1 = readInt();
({
intptr_t arg2 = run(arg1);
printInt((int64_t)arg2);
});
}));
}

