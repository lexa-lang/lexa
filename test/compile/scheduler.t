  $ sstal ../lexi/scheduler/main.ir -o main.c
  $ cat main.c
  #include <stdint.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include <stdbool.h>
  #include <string.h>
  #include <defs.h>
  #include <datastructure.h>
  
  static i64 __handle_body_lifted_11__(i64,i64);
   i64 __exn_stub_lifted_12___throw(i64*,i64);
  static i64 __handle_body_lifted_13__(i64,i64);
  FAST_SWITCH_DECORATOR
   i64 __process_stub_lifted_14___fork(i64*,i64,i64);
  FAST_SWITCH_DECORATOR
   i64 __process_stub_lifted_14___yield(i64*,i64,i64);
  static i64 __fun_lifted_15__(i64,i64);
  static i64 __handle_body_lifted_16__(i64,i64);
   i64 __tick_stub_lifted_17___tick(i64*,i64);
  static i64 __repeat_lifted_9__(i64,i64);
  static i64 __step_lifted_8__(i64,i64,i64,i64);
  static i64 __run_lifted_7__(i64,i64,i64);
  static i64 __scheduler_lifted_6__(i64,i64);
  static i64 __spawn_lifted_5__(i64,i64,i64);
  static i64 __driver_lifted_4__(i64,i64);
  static i64 __jobs_lifted_3__(i64,i64,i64,i64);
  static i64 __job_lifted_2__(i64,i64);
  static i64 __queueDeqExn_lifted_1__(i64,i64,i64);
  static closure_t* repeat;
  static closure_t* step;
  static closure_t* run;
  static closure_t* scheduler;
  static closure_t* spawn;
  static closure_t* driver;
  static closure_t* jobs;
  static closure_t* job;
  static closure_t* queueDeqExn;
  enum Process {yield,fork};
  
  enum Tick {tick};
  
  enum Exn {throw};
  
  static i64 __queueDeqExn_lifted_1__(i64 __env__,i64 q,i64 exn_stub) {
  return(((((i64)(queueIsEmpty((queue_t*)q)))) ? (RAISE(exn_stub, throw, ((i64)0))) : (((i64)(queueDeq((queue_t*)q))))));
  }
  
  static i64 __job_lifted_2__(i64 __env__,i64 process_stub) {
  return((RAISE(process_stub, yield, ((i64)0))));
  }
  
  static i64 __jobs_lifted_3__(i64 __env__,i64 i,i64 process_stub,i64 tick_stub) {
  return(((i == 0) ? 0 : ({(RAISE(process_stub, fork, ((i64)job)));
  ({(RAISE(tick_stub, tick, ((i64)0)));
  (({__attribute__((musttail))
   return ((i64(*)(i64, i64, i64, i64))__jobs_lifted_3__)(0,(i - 1),process_stub,tick_stub); 0;}));});})));
  }
  
  static i64 __driver_lifted_4__(i64 __env__,i64 job_queue) {
  return(({(HANDLE(__handle_body_lifted_11__, ({ABORT, __exn_stub_lifted_12___throw}), ((i64)driver, (i64)job_queue, (i64)queueDeqExn)));
  0;}));
  }
  
  static i64 __spawn_lifted_5__(i64 __env__,i64 f,i64 job_queue) {
  return((HANDLE(__handle_body_lifted_13__, ({SINGLESHOT, __process_stub_lifted_14___yield}, {SINGLESHOT, __process_stub_lifted_14___fork}), ((i64)f, (i64)job_queue, (i64)spawn))));
  }
  
  static i64 __scheduler_lifted_6__(i64 __env__,i64 f) {
  return(({i64 job_queue = (i64)(((i64)(queueMake())));
  ({(((i64(*)(i64, i64, i64))__spawn_lifted_5__)(0,f,job_queue));
  (((i64(*)(i64, i64))__driver_lifted_4__)(0,job_queue));});}));
  }
  
  static i64 __run_lifted_7__(i64 __env__,i64 n_jobs,i64 init) {
  return(({i64 c = (i64)(({i64 temp = (i64)malloc(1 * sizeof(i64));
  ((i64*)temp)[0] = (i64)init;
  temp;
  }));
  ({(HANDLE(__handle_body_lifted_16__, ({TAIL, __tick_stub_lifted_17___tick}), ((i64)c, (i64)jobs, (i64)n_jobs, (i64)scheduler)));
  (((i64*)c)[0]);});}));
  }
  
  static i64 __step_lifted_8__(i64 __env__,i64 i,i64 acc,i64 n_jobs) {
  return(((i == 0) ? acc : (({__attribute__((musttail))
   return ((i64(*)(i64, i64, i64, i64))__step_lifted_8__)(0,(i - 1),(((i64(*)(i64, i64, i64))__run_lifted_7__)(0,n_jobs,acc)),n_jobs); 0;}))));
  }
  
  static i64 __repeat_lifted_9__(i64 __env__,i64 n_jobs) {
  return((((i64(*)(i64, i64, i64, i64))__step_lifted_8__)(0,1000,0,n_jobs)));
  }
  
  int main(int argc, char *argv[]) {
  init_stack_pool();
  repeat = malloc(sizeof(closure_t));
  repeat->func_pointer = (i64)__repeat_lifted_9__;
  repeat->env = (i64)NULL;
  step = malloc(sizeof(closure_t));
  step->func_pointer = (i64)__step_lifted_8__;
  step->env = (i64)NULL;
  run = malloc(sizeof(closure_t));
  run->func_pointer = (i64)__run_lifted_7__;
  run->env = (i64)NULL;
  scheduler = malloc(sizeof(closure_t));
  scheduler->func_pointer = (i64)__scheduler_lifted_6__;
  scheduler->env = (i64)NULL;
  spawn = malloc(sizeof(closure_t));
  spawn->func_pointer = (i64)__spawn_lifted_5__;
  spawn->env = (i64)NULL;
  driver = malloc(sizeof(closure_t));
  driver->func_pointer = (i64)__driver_lifted_4__;
  driver->env = (i64)NULL;
  jobs = malloc(sizeof(closure_t));
  jobs->func_pointer = (i64)__jobs_lifted_3__;
  jobs->env = (i64)NULL;
  job = malloc(sizeof(closure_t));
  job->func_pointer = (i64)__job_lifted_2__;
  job->env = (i64)NULL;
  queueDeqExn = malloc(sizeof(closure_t));
  queueDeqExn->func_pointer = (i64)__queueDeqExn_lifted_1__;
  queueDeqExn->env = (i64)NULL;
  
  i64 __res__ = ({i64 arg1 = (i64)(((i64)(readInt())));
  ({i64 arg2 = (i64)(((i64(*)(i64, i64))__repeat_lifted_9__)(0,arg1));
  ({(((i64)(printInt((int64_t)arg2))));
  0;});});});
  destroy_stack_pool();
  return((int)__res__);}
   i64 __tick_stub_lifted_17___tick(i64* __env__,i64 _) {
  return(({i64 c = (i64)(((i64*)__env__)[0]);
  ({i64 jobs = (i64)(((i64*)__env__)[1]);
  ({i64 n_jobs = (i64)(((i64*)__env__)[2]);
  ({i64 scheduler = (i64)(((i64*)__env__)[3]);
  ({(((i64*)c)[0] = ((((i64*)c)[0]) + 1));
  0;});});});});}));
  }
  
  static i64 __handle_body_lifted_16__(i64 __env__,i64 tick_stub) {
  return(({i64 c = (i64)(((i64*)__env__)[0]);
  ({i64 jobs = (i64)(((i64*)__env__)[1]);
  ({i64 n_jobs = (i64)(((i64*)__env__)[2]);
  ({i64 scheduler = (i64)(((i64*)__env__)[3]);
  (((i64(*)(i64, i64))__scheduler_lifted_6__)(0,(({closure_t* __c__ = malloc(sizeof(closure_t));
  __c__->func_pointer = (i64)__fun_lifted_15__;
  __c__->env = (i64)malloc(3 * sizeof(i64));
  ((i64*)(__c__->env))[0] = jobs;
  ((i64*)(__c__->env))[1] = n_jobs;
  ((i64*)(__c__->env))[2] = tick_stub;
  (i64)__c__;}))));});});});}));
  }
  
  static i64 __fun_lifted_15__(i64 __env__,i64 process_stub) {
  return(({i64 jobs = (i64)(((i64*)__env__)[0]);
  ({i64 n_jobs = (i64)(((i64*)__env__)[1]);
  ({i64 tick_stub = (i64)(((i64*)__env__)[2]);
  (((i64(*)(i64, i64, i64, i64))__jobs_lifted_3__)(0,n_jobs,process_stub,tick_stub));});});}));
  }
  
  FAST_SWITCH_DECORATOR
   i64 __process_stub_lifted_14___yield(i64* __env__,i64 _,i64 k) {
  return(({i64 f = (i64)(((i64*)__env__)[0]);
  ({i64 job_queue = (i64)(((i64*)__env__)[1]);
  ({i64 spawn = (i64)(((i64*)__env__)[2]);
  (((i64)(queueEnq((queue_t*)job_queue, (int64_t)k))));});});}));
  }
  
  FAST_SWITCH_DECORATOR
   i64 __process_stub_lifted_14___fork(i64* __env__,i64 g,i64 k) {
  return(({i64 f = (i64)(((i64*)__env__)[0]);
  ({i64 job_queue = (i64)(((i64*)__env__)[1]);
  ({i64 spawn = (i64)(((i64*)__env__)[2]);
  ({(((i64)(queueEnq((queue_t*)job_queue, (int64_t)k))));
  (((i64(*)(i64, i64, i64))__spawn_lifted_5__)(0,g,job_queue));});});});}));
  }
  
  static i64 __handle_body_lifted_13__(i64 __env__,i64 process_stub) {
  return(({i64 f = (i64)(((i64*)__env__)[0]);
  ({i64 job_queue = (i64)(((i64*)__env__)[1]);
  ({i64 spawn = (i64)(((i64*)__env__)[2]);
  (({closure_t* __clo__ = (closure_t*)f;
  i64 __f__ = (i64)(__clo__->func_pointer);
  i64 __env__ = (i64)(__clo__->env);
  ((i64(*)(i64, i64))__f__)(__env__,process_stub);
  }));});});}));
  }
  
   i64 __exn_stub_lifted_12___throw(i64* __env__,i64 _) {
  return(({i64 driver = (i64)(((i64*)__env__)[0]);
  ({i64 job_queue = (i64)(((i64*)__env__)[1]);
  ({i64 queueDeqExn = (i64)(((i64*)__env__)[2]);
  0;});});}));
  }
  
  static i64 __handle_body_lifted_11__(i64 __env__,i64 exn_stub) {
  return(({i64 driver = (i64)(((i64*)__env__)[0]);
  ({i64 job_queue = (i64)(((i64*)__env__)[1]);
  ({i64 queueDeqExn = (i64)(((i64*)__env__)[2]);
  ({i64 k = (i64)(((i64(*)(i64, i64, i64))__queueDeqExn_lifted_1__)(0,job_queue,exn_stub));
  ({(FINAL_THROW(k, 0));
  (((i64(*)(i64, i64))__driver_lifted_4__)(0,job_queue));});});});});}));
  }
  
