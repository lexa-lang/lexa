module main

import std/os/env
import std/core/exn
import dequeue

named effect tick
  fun tick(): ()

named rec effect process
  ctl yield(): ()
  ctl fork(p: (r: hnd/ev<process>) -> pure ()): ()

fun scheduler(prog)
  var queue := emptyQueue()
  fun driver(): <pure, local<_h>> ()
    try {
      val (k,q) = queue.popBack()
      queue := q
      k()
      driver()
    } fn(e) ()
    

  fun spawn(prog1)
    with r_process <- named handler
      raw ctl yield() 
        queue := queue.pushFront(fn() rcontext.resume(()))
      raw ctl fork(p)
        queue := queue.pushFront(fn() rcontext.resume(()))
        spawn(p)
    prog1(r_process)
  spawn(prog)
  driver()

fun job(r_process: hnd/ev<process>): pure ()
  r_process.yield()
  
fun jobs(r_process: hnd/ev<process>, r_tick: hnd/ev<tick>, n_jobs): <pure> ()
  var i: int := 0;
  while {i < n_jobs}
    r_process.fork(job)
    r_tick.tick()
    i := i + 1

fun run(n_jobs : int)
  var c := 0
  with r_tick <- named handler
    fun tick() c := c + 1
  fun entry(r_process)
    jobs(r_process, r_tick, n_jobs)
  scheduler(entry)


pub fun main()
  val n = get-args().head("").parse-int().default(5)
  val r = run(n)
  println(r)