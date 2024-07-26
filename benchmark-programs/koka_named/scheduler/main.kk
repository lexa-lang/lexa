// NB: This program currently does not compile https://github.com/koka-lang/koka/issues/484

module main

import std/os/env
import dequeue

named effect tick
  fun tick(): ()

named rec effect process
   ctl yield(): ()
   ctl fork(g: (r: hnd/ev<process>) -> <div, exn, st<global>> ()): ()

fun scheduler(f)
  val q: ref<global, dequeue<() -> <div, st<global>|e> ()>> = ref(emptyQueue())

  fun spawn(f)
    with r_process <- named handler
      raw ctl yield()
        q := (!q).pushBack(fn() rcontext.resume(()))
      raw ctl fork(g)
        q := (!q).pushBack(fn() rcontext.resume(()))
        spawn(g)
    f(r_process)

  fun driver(): <st<global>, pure|e> ()
    with handler
      final ctl throw-exn(err) ()
    val res = (!q).popFront()
    q := snd(res)
    mask<exn>
      fst(res)()
      driver()

  spawn(f)
  driver()

fun job(r_process: hnd/ev<process>): <pure> ()
  r_process.yield()
  
fun jobs(n_jobs: int, r_process: hnd/ev<process>, r_tick: hnd/ev<tick>): <tick, pure> ()
  var i: int := 0;
  while {i < n_jobs}
    r_process.fork(job)
    r_tick.tick()
    i := i + 1

fun run(n_jobs : int)
  var c := 0
  with r_tick <- named handler
    fun tick() c := c + 1
  scheduler(fn (r_process: hnd/ev<process>) jobs(n_jobs, r_process, r_tick))
  c

fun repeat(n_jobs : int)
  fun step(i: int, acc: int)
    if i == 0 then
      acc
    else 
      val r: int = run(n_jobs)
      step(i - 1, acc + r)
  step(100, 0)


pub fun main()
  val n = get-args().head("").parse-int().default(5)
  val r = repeat(n)
  println(r)