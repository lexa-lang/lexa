module main

import std/os/env
import dequeue

effect tick
  fun tick(): ()

rec effect process
  fun yield(): ()
  fun fork(p: () -> <process> ()): ()

fun scheduler(prog): ()
  ()


fun job(): process ()
  ()
  

fun run(n_jobs : int)
  var c := 0
  fun jobs(): <process, tick, pure> ()
    var i: int := 0;
    while {i < n_jobs}
      fork(job)
      tick()
      i := i + 1
  with handler
    fun tick() c := c + 1
  scheduler(jobs)


pub fun main()
  val n = get-args().head("").parse-int().default(5)
  val r = run(n)
  println(r)