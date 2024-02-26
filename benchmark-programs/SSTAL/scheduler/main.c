#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <defs.h>
#include <datastructure.h>

#define i64 intptr_t

static i64 spawn(i64, i64, i64);

i64 ret_val;

i64 job(i64 state, handler_t* sch_stub){
  ((i64*)state)[0] += 1;
  RAISE(sch_stub, 0, 0);
  ((i64*)state)[0] += 1;
  return 0;
}

i64 loop(i64 i, i64 job_closure, handler_t* sch_stub){
  if (i == 0) {
    return 0;
  } else {
    RAISE(sch_stub, 1, job_closure);
    return loop(i - 1, job_closure, sch_stub);
  }
}

i64 entry(i64 env, handler_t* sch_stub){
  i64 n = ((i64*)env)[0];
  i64 job_closure = ((i64*)env)[1];
  return loop(n, job_closure, sch_stub);
}

static i64 suspend(i64 job_queue, i64 k){
  queueEnq((queue_t*)job_queue, k);
  return 0;
}

static i64 runnext(i64 job_queue){
  return ({
    (queueIsEmpty((queue_t*)job_queue)) ? ({
      0;
    }) : ({
      i64 k = (i64)queueDeq((queue_t*)job_queue);
      FINAL_THROW(k, 0);
    });
  });
}

i64 yield(i64 env, i64 _, i64 k){
  HANDLER_PREAMBLE(k);
  mp_jmpbuf_t* ctx_jb = ((exchanger_t*)k)->ctx_jb;

  i64 suspend_closure = ((i64*)env)[1];
  i64 suspend_func = ((i64*)suspend_closure)[0];
  i64 job_queue = ((i64*)suspend_closure)[1];
  ((i64(*)(i64, i64))suspend_func)(job_queue, k);

  i64 runnext_closure = ((i64*)env)[2];
  i64 runnext_func = ((i64*)runnext_closure)[0];
  i64 job_queue2 = ((i64*)runnext_closure)[1];
  ret_val = ((i64(*)(i64))runnext_func)(job_queue2);
  mp_longjmp(ctx_jb);
}

i64 fork(i64 env, i64 job_closure, i64 k){
  HANDLER_PREAMBLE(k);
  mp_jmpbuf_t* ctx_jb = ((exchanger_t*)k)->ctx_jb;

  i64 suspend_closure = ((i64*)env)[1];
  i64 suspend_func = ((i64*)suspend_closure)[0];
  i64 job_queue = ((i64*)suspend_closure)[1];
  ((i64(*)(i64, i64))suspend_func)(job_queue, k);
  ret_val = ((i64(*)(i64, i64, i64))spawn)(job_closure, ((i64*)env)[1], ((i64*)env)[2]);

  mp_longjmp(ctx_jb);
}

static i64 body(handler_t * sch_stub) {
  ret_val = ({
    i64 job_closure = sch_stub->env[0];
    i64 job_func = ((i64*)job_closure)[0];
    i64 job_env = ((i64*)job_closure)[1];
    ((i64 (*)(i64, handler_t*))job_func)(job_env, sch_stub);
  });

  mp_longjmp(sch_stub->exchanger->ctx_jb);
  __builtin_unreachable();
}

static i64 spawn(i64 job_closure, i64 suspend_closure, i64 runnext_closure){
    i64 *env = (i64*)xmalloc(sizeof(i64) * 3);
    env[0] = job_closure;
    env[1] = suspend_closure;
    env[2] = runnext_closure;
    HANDLE_TWO(body, SINGLESHOT, yield, SINGLESHOT, fork, env);

    i64 runnext_func = ((i64*)runnext_closure)[0];
    i64 job_queue = ((i64*)runnext_closure)[1];
    return ((i64(*)(i64))runnext_func)(job_queue);
}

i64 startScheduler(i64 init_closure){
  i64 job_queue = (i64)queueMake();
  i64 suspend_closure = (i64)xmalloc(sizeof(i64) * 2);
  ((i64*)suspend_closure)[0] = (i64)suspend;
  ((i64*)suspend_closure)[1] = (i64)job_queue;

  i64 runnext_closure = (i64)xmalloc(sizeof(i64) * 2);
  ((i64*)runnext_closure)[0] = (i64)runnext;
  ((i64*)runnext_closure)[1] = (i64)job_queue;

  spawn(init_closure, suspend_closure, runnext_closure);
  return 0;
}

static i64 run(i64 n){
  i64 state = (i64)xmalloc(sizeof(i64) * 1);
  ((i64*)state)[0] = 0;

  i64 job_closure = (i64)xmalloc(sizeof(i64) * 2);
  ((i64*)job_closure)[0] = (i64)job;
  ((i64*)job_closure)[1] = (i64)state;

  i64 entry_env = (i64)xmalloc(sizeof(i64) * 2);
  ((i64*)entry_env)[0] = (i64)n;
  ((i64*)entry_env)[1] = (i64)job_closure;

  i64 entry_closure = (i64)xmalloc(sizeof(i64) * 2);
  ((i64*)entry_closure)[0] = (i64)entry;
  ((i64*)entry_closure)[1] = (i64)entry_env;

  startScheduler(entry_closure);

  return ((i64*)state)[0];
}

int main(int argc, char *argv[]){
    init_stack_pool();
    printInt(run(readInt()));
    destroy_stack_pool();
    return 0;
}
