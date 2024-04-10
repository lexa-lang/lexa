  $ sstal ../lexi/scheduler/main.ir -o main.c
  $ cat main.c
  #include <stdint.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include <stdbool.h>
  #include <string.h>
  #include <defs.h>
  #include <datastructure.h>
  
  static i64 repeat(i64);
  static i64 step(i64,i64,i64);
  static i64 run(i64,i64);
  static i64 body_run(i64,i64);
   i64 tick(i64*,i64);
  static i64 scheduler(i64);
  static i64 spawn(i64,i64);
  static i64 driver(i64);
   i64 throw(i64*,i64);
  static i64 body_driver(i64,i64);
  static i64 body(i64,i64);
  FAST_SWITCH_DECORATOR
   i64 fork(i64*,i64,i64);
  FAST_SWITCH_DECORATOR
   i64 yield(i64*,i64,i64);
  static i64 jobs(i64,i64,i64,i64);
  static i64 entry(i64,i64);
  static i64 job(i64,i64);
  static i64 queueDeqExn(i64,i64);
  
  
  
  static i64 queueDeqExn(i64 q,i64 exn_stub) {
  return(({i64 cond = (i64)(((i64)(queueIsEmpty((queue_t*)q))));
  (cond) ? (RAISE(exn_stub, 0, (0))) : (((i64)(queueDeq((queue_t*)q))));}));
  }
  
  static i64 job(i64 env,i64 sch_stub) {
  return(RAISE(sch_stub, 0, (0)));
  }
  
  static i64 entry(i64 env,i64 sch_stub) {
  return(({i64 n_jobs = (i64)(((i64*)env)[0]);
  ({i64 job_closure = (i64)(((i64*)env)[1]);
  ({i64 tick_stub = (i64)(((i64*)env)[2]);
  ((i64(*)(i64, i64, i64, i64))jobs)(n_jobs,job_closure,sch_stub,tick_stub);});});}));
  }
  
  static i64 jobs(i64 i,i64 job_closure,i64 sch_stub,i64 tick_stub) {
  return(({i64 cond = (i64)(i == 0);
  (cond) ? (0) : (({i64 _ = (i64)(RAISE(sch_stub, 1, (job_closure)));
  ({i64 a = (i64)(RAISE(tick_stub, 0, (0)));
  ({i64 i0 = (i64)(i - 1);
  ((i64(*)(i64, i64, i64, i64))jobs)(i0,job_closure,sch_stub,tick_stub);});});}));}));
  }
  
  FAST_SWITCH_DECORATOR
   i64 yield(i64* env,i64 _,i64 k) {
  return(({i64 job_queue = (i64)(((i64*)env)[1]);
  ((i64)(queueEnq((queue_t*)job_queue, (int64_t)k)));}));
  }
  
  FAST_SWITCH_DECORATOR
   i64 fork(i64* env,i64 newjob_closure,i64 k) {
  return(({i64 job_queue = (i64)(((i64*)env)[1]);
  ({i64 _ = (i64)(((i64)(queueEnq((queue_t*)job_queue, (int64_t)k))));
  ((i64(*)(i64, i64))spawn)(newjob_closure,job_queue);});}));
  }
  
  static i64 body(i64 env,i64 sch_stub) {
  return(({i64 job_closure = (i64)(((i64*)env)[0]);
  ({i64 job_func = (i64)(((i64*)job_closure)[0]);
  ({i64 job_env = (i64)(((i64*)job_closure)[1]);
  ((i64(*)(i64, i64))job_func)(job_env,sch_stub);});});}));
  }
  
  static i64 body_driver(i64 env,i64 exn_stub) {
  return(({i64 job_queue = (i64)(((i64*)env)[0]);
  ({i64 k = (i64)(((i64(*)(i64, i64))queueDeqExn)(job_queue,exn_stub));
  ({i64 _ = (i64)(FINAL_THROW(k, 0));
  ((i64(*)(i64))driver)(job_queue);});});}));
  }
  
   i64 throw(i64* env,i64 _) {
  return(0);
  }
  
  static i64 driver(i64 job_queue) {
  return(({i64 _ = (i64)(HANDLE(body_driver, ({ABORT, throw}), (job_queue)));
  0;}));
  }
  
  static i64 spawn(i64 job_closure,i64 job_queue) {
  return(HANDLE(body, ({SINGLESHOT, yield}, {SINGLESHOT, fork}), (job_closure, job_queue)));
  }
  
  static i64 scheduler(i64 init_closure) {
  return(({i64 job_queue = (i64)(((i64)(queueMake())));
  ({i64 _ = (i64)(((i64(*)(i64, i64))spawn)(init_closure,job_queue));
  ((i64(*)(i64))driver)(job_queue);});}));
  }
  
   i64 tick(i64* env,i64 _) {
  return(({i64 c = (i64)(((i64*)env)[1]);
  ({i64 v1 = (i64)(((i64*)c)[0]);
  ({i64 v2 = (i64)(v1 + 1);
  ({i64 _ = (i64)(((i64*)c)[0] = v2);
  0;});});});}));
  }
  
  static i64 body_run(i64 env,i64 tick_stub) {
  return(({i64 n_jobs = (i64)(((i64*)env)[0]);
  ({i64 empty = (i64)(({i64 temp = (i64)malloc(0 * sizeof(i64));
  
  temp;
  }));
  ({i64 job_closure = (i64)(({i64 temp = (i64)malloc(2 * sizeof(i64));
  ((i64*)temp)[0] = (i64)job;
  ((i64*)temp)[1] = (i64)empty;
  temp;
  }));
  ({i64 entry_env = (i64)(({i64 temp = (i64)malloc(3 * sizeof(i64));
  ((i64*)temp)[0] = (i64)n_jobs;
  ((i64*)temp)[1] = (i64)job_closure;
  ((i64*)temp)[2] = (i64)tick_stub;
  temp;
  }));
  ({i64 entry_closure = (i64)(({i64 temp = (i64)malloc(2 * sizeof(i64));
  ((i64*)temp)[0] = (i64)entry;
  ((i64*)temp)[1] = (i64)entry_env;
  temp;
  }));
  ((i64(*)(i64))scheduler)(entry_closure);});});});});}));
  }
  
  static i64 run(i64 n_jobs,i64 init) {
  return(({i64 c = (i64)(({i64 temp = (i64)malloc(1 * sizeof(i64));
  ((i64*)temp)[0] = (i64)init;
  temp;
  }));
  ({i64 _ = (i64)(HANDLE(body_run, ({TAIL, tick}), (n_jobs, c)));
  ({i64 v = (i64)(((i64*)c)[0]);
  v;});});}));
  }
  
  static i64 step(i64 i,i64 acc,i64 n_jobs) {
  return(({i64 cond = (i64)(i == 0);
  (cond) ? (acc) : (({i64 i_dec = (i64)(i - 1);
  ({i64 acc2 = (i64)(((i64(*)(i64, i64))run)(n_jobs,acc));
  ((i64(*)(i64, i64, i64))step)(i_dec,acc2,n_jobs);});}));}));
  }
  
  static i64 repeat(i64 n_jobs) {
  return(((i64(*)(i64, i64, i64))step)(1000,0,n_jobs));
  }
  
  int main(int argc, char *argv[]) {
  init_stack_pool();
  i64 __res__ = ({i64 arg1 = (i64)(((i64)(readInt())));
  ({i64 arg2 = (i64)(((i64(*)(i64))repeat)(arg1));
  ({i64 _ = (i64)(((i64)(printInt((int64_t)arg2))));
  0;});});});
  destroy_stack_pool();
  return((int)__res__);
  }
  
