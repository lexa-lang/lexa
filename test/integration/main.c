#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <defs.h>
#include <datastructure.h>

static i64 __handle_body_lifted_4__(i64,i64);
 i64 __state_stub_lifted_5___set(i64*,i64);
 i64 __state_stub_lifted_5___get(i64*,i64);
static i64 __run_lifted_2__(i64,i64);
static i64 __countdown_lifted_1__(i64,i64);
static closure_t* run;
static closure_t* countdown;
enum State {get,set};

static i64 __countdown_lifted_1__(i64 __env__,i64 state_stub) {
return(({i64 i = (i64)(RAISE(state_stub, get, ((i64)0)));
((i == 0) ? i : ({(RAISE(state_stub, set, ((i64)i-1)));
(({__attribute__((musttail))
 return ((i64(*)(i64, i64))__countdown_lifted_1__)(0,state_stub); 0;}));}));}));
}

static i64 __run_lifted_2__(i64 __env__,i64 n) {
return(({i64 s = (i64)(({i64 __field_0__ = (i64)n;
i64* __newref__ = malloc(1 * sizeof(i64));
__newref__[0] = __field_0__;
(i64)__newref__;}));
(HANDLE(__handle_body_lifted_4__, ({TAIL, __state_stub_lifted_5___get}, {TAIL, __state_stub_lifted_5___set}), ((i64)countdown, (i64)s)));}));
}

int main(int argc, char *argv[]) {
init_stack_pool();
run = malloc(sizeof(closure_t));
run->func_pointer = (i64)__run_lifted_2__;
run->env = (i64)NULL;
countdown = malloc(sizeof(closure_t));
countdown->func_pointer = (i64)__countdown_lifted_1__;
countdown->env = (i64)NULL;

i64 __res__ = ({(((i64)(printInt((int64_t)(((i64(*)(i64, i64))__run_lifted_2__)(0,(((i64)(readInt())))))))));
0;});
destroy_stack_pool();
return((int)__res__);}
 i64 __state_stub_lifted_5___get(i64* __env__,i64 _) {
return(({i64 countdown = (i64)(((i64*)__env__)[0]);
({i64 s = (i64)(((i64*)__env__)[1]);
(((i64*)s)[0]);});}));
}

 i64 __state_stub_lifted_5___set(i64* __env__,i64 i) {
return(({i64 countdown = (i64)(((i64*)__env__)[0]);
({i64 s = (i64)(((i64*)__env__)[1]);
({(((i64*)s)[0] = i);
0;});});}));
}

static i64 __handle_body_lifted_4__(i64 __env__,i64 state_stub) {
return(({i64 countdown = (i64)(((i64*)__env__)[0]);
({i64 s = (i64)(((i64*)__env__)[1]);
(((i64(*)(i64, i64))__countdown_lifted_1__)(0,state_stub));});}));
}

