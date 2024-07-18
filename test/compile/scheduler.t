  $ sstal ../lexi/scheduler/main.ir -o main.c
  $ cat main.c
  #include <stdint.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include <stdbool.h>
  #include <string.h>
  #include <defs.h>
  #include <datastructure.h>
  
  static i64 __repeat_lifted_13__(i64,i64);
  static i64 __step_lifted_12__(i64,i64,i64,i64);
  static i64 __run_lifted_11__(i64,i64,i64);
  static i64 body_run(i64,i64);
   i64 tick_tick(i64*,i64);
  static i64 __scheduler_lifted_9__(i64,i64);
  static i64 __spawn_lifted_8__(i64,i64,i64);
  static i64 __driver_lifted_7__(i64,i64);
   i64 exn_throw(i64*,i64);
  static i64 body_driver(i64,i64);
  static i64 body(i64,i64);
  FAST_SWITCH_DECORATOR
   i64 process_fork(i64*,i64,i64);
  FAST_SWITCH_DECORATOR
   i64 process_yield(i64*,i64,i64);
  static i64 __jobs_lifted_4__(i64,i64,i64,i64,i64);
  static i64 __entry_lifted_3__(i64,i64,i64);
  static i64 __job_lifted_2__(i64,i64,i64);
  static i64 __queueDeqExn_lifted_1__(i64,i64,i64);
  static closure_t* repeat;
  static closure_t* step;
  static closure_t* run;
  static closure_t* scheduler;
  static closure_t* spawn;
  static closure_t* driver;
  static closure_t* jobs;
  static closure_t* entry;
  static closure_t* job;
  static closure_t* queueDeqExn;
  enum Process {yield,fork};
  
  enum Tick {tick};
  
  enum Exn {throw};
  
  static i64 __queueDeqExn_lifted_1__(i64 __env__,i64 q,i64 exn_stub) {
  return(((((i64)(queueIsEmpty((queue_t*)q)))) ? (RAISE(exn_stub, throw, (0))) : (((i64)(queueDeq((queue_t*)q))))));
  }
  
  static i64 __job_lifted_2__(i64 __env__,i64 env,i64 sch_stub) {
  return((RAISE(sch_stub, yield, (0))));
  }
  
  static i64 __entry_lifted_3__(i64 __env__,i64 env,i64 sch_stub) {
  return(({i64 n_jobs = (i64)(((i64*)env)[0]);
  ({i64 job_closure = (i64)(((i64*)env)[1]);
  ({i64 tick_stub = (i64)(((i64*)env)[2]);
  (((i64(*)(i64, i64, i64, i64, i64))__jobs_lifted_4__)(0,n_jobs,job_closure,sch_stub,tick_stub));});});}));
  }
  
  static i64 __jobs_lifted_4__(i64 __env__,i64 i,i64 job_closure,i64 sch_stub,i64 tick_stub) {
  return(((i == 0) ? 0 : ({(RAISE(sch_stub, fork, (job_closure)));
  ({(RAISE(tick_stub, tick, (0)));
  (({__attribute__((musttail))
   return ((i64(*)(i64, i64, i64, i64, i64))__jobs_lifted_4__)(0,(i - 1),job_closure,sch_stub,tick_stub); 0;}));});})));
  }
  
  FAST_SWITCH_DECORATOR
   i64 process_yield(i64* env,i64 _,i64 k) {
  return(({i64 job_queue = (i64)(((i64*)env)[1]);
  (((i64)(queueEnq((queue_t*)job_queue, (int64_t)k))));}));
  }
  
  FAST_SWITCH_DECORATOR
   i64 process_fork(i64* env,i64 newjob_closure,i64 k) {
  return(({i64 job_queue = (i64)(((i64*)env)[1]);
  ({(((i64)(queueEnq((queue_t*)job_queue, (int64_t)k))));
  (((i64(*)(i64, i64, i64))__spawn_lifted_8__)(0,newjob_closure,job_queue));});}));
  }
  
  static i64 body(i64 env,i64 sch_stub) {
  return(({i64 job_closure = (i64)(((i64*)env)[0]);
  ({i64 job_func = (i64)(((i64*)job_closure)[0]);
  ({i64 job_env = (i64)(((i64*)job_closure)[1]);
  (({closure_t* __clo__ = (closure_t*)job_func;
  i64 __f__ = (i64)(__clo__->func_pointer);
  i64 __env__ = (i64)(__clo__->env);
  ((i64(*)(i64, i64, i64))__f__)(__env__,job_env,sch_stub);
  }));});});}));
  }
  
  static i64 body_driver(i64 env,i64 exn_stub) {
  return(({i64 job_queue = (i64)(((i64*)env)[0]);
  ({i64 k = (i64)(((i64(*)(i64, i64, i64))__queueDeqExn_lifted_1__)(0,job_queue,exn_stub));
  ({(FINAL_THROW(k, 0));
  (((i64(*)(i64, i64))__driver_lifted_7__)(0,job_queue));});});}));
  }
  
   i64 exn_throw(i64* env,i64 _) {
  return(0);
  }
  
  static i64 __driver_lifted_7__(i64 __env__,i64 job_queue) {
  return(({(HANDLE(body_driver, ({ABORT, exn_throw}), (job_queue)));
  0;}));
  }
  
  static i64 __spawn_lifted_8__(i64 __env__,i64 job_closure,i64 job_queue) {
  return((HANDLE(body, ({SINGLESHOT, process_yield}, {SINGLESHOT, process_fork}), (job_closure, job_queue))));
  }
  
  static i64 __scheduler_lifted_9__(i64 __env__,i64 init_closure) {
  return(({i64 job_queue = (i64)(((i64)(queueMake())));
  ({(((i64(*)(i64, i64, i64))__spawn_lifted_8__)(0,init_closure,job_queue));
  (((i64(*)(i64, i64))__driver_lifted_7__)(0,job_queue));});}));
  }
  
   i64 tick_tick(i64* env,i64 _) {
  return(({i64 c = (i64)(((i64*)env)[1]);
  ({(((i64*)c)[0] = ((((i64*)c)[0]) + 1));
  0;});}));
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
  (((i64(*)(i64, i64))__scheduler_lifted_9__)(0,entry_closure));});});});});}));
  }
  
  static i64 __run_lifted_11__(i64 __env__,i64 n_jobs,i64 init) {
  return(({i64 c = (i64)(({i64 temp = (i64)malloc(1 * sizeof(i64));
  ((i64*)temp)[0] = (i64)init;
  temp;
  }));
  ({(HANDLE(body_run, ({TAIL, tick_tick}), (n_jobs, c)));
  (((i64*)c)[0]);});}));
  }
  
  static i64 __step_lifted_12__(i64 __env__,i64 i,i64 acc,i64 n_jobs) {
  return(((i == 0) ? acc : (({__attribute__((musttail))
   return ((i64(*)(i64, i64, i64, i64))__step_lifted_12__)(0,(i - 1),(((i64(*)(i64, i64, i64))__run_lifted_11__)(0,n_jobs,acc)),n_jobs); 0;}))));
  }
  
  static i64 __repeat_lifted_13__(i64 __env__,i64 n_jobs) {
  return((((i64(*)(i64, i64, i64, i64))__step_lifted_12__)(0,1000,0,n_jobs)));
  }
  
  int main(int argc, char *argv[]) {
  init_stack_pool();
  repeat = malloc(sizeof(closure_t));
  repeat->func_pointer = (i64)__repeat_lifted_13__;
  repeat->env = (i64)NULL;
  step = malloc(sizeof(closure_t));
  step->func_pointer = (i64)__step_lifted_12__;
  step->env = (i64)NULL;
  run = malloc(sizeof(closure_t));
  run->func_pointer = (i64)__run_lifted_11__;
  run->env = (i64)NULL;
  scheduler = malloc(sizeof(closure_t));
  scheduler->func_pointer = (i64)__scheduler_lifted_9__;
  scheduler->env = (i64)NULL;
  spawn = malloc(sizeof(closure_t));
  spawn->func_pointer = (i64)__spawn_lifted_8__;
  spawn->env = (i64)NULL;
  driver = malloc(sizeof(closure_t));
  driver->func_pointer = (i64)__driver_lifted_7__;
  driver->env = (i64)NULL;
  jobs = malloc(sizeof(closure_t));
  jobs->func_pointer = (i64)__jobs_lifted_4__;
  jobs->env = (i64)NULL;
  entry = malloc(sizeof(closure_t));
  entry->func_pointer = (i64)__entry_lifted_3__;
  entry->env = (i64)NULL;
  job = malloc(sizeof(closure_t));
  job->func_pointer = (i64)__job_lifted_2__;
  job->env = (i64)NULL;
  queueDeqExn = malloc(sizeof(closure_t));
  queueDeqExn->func_pointer = (i64)__queueDeqExn_lifted_1__;
  queueDeqExn->env = (i64)NULL;
  
  i64 __res__ = ({i64 arg1 = (i64)(((i64)(readInt())));
  ({i64 arg2 = (i64)(((i64(*)(i64, i64))__repeat_lifted_13__)(0,arg1));
  ({(((i64)(printInt((int64_t)arg2))));
  0;});});});
  destroy_stack_pool();
  return((int)__res__);}
