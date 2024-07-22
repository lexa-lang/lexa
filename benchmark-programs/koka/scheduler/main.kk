module main

import std/os/env
import dequeue

effect tick
  fun tick(): ()

rec effect process
   ctl yield(): ()
   ctl fork(g: () -> <process, div, exn, st<global>> ()): ()

fun scheduler(f: () -> <process, div, st<global>, exn|e> ()): <st<global>, pure|e> ()
  val q: ref<global, dequeue<() -> <div, st<global>|e> ()>> = ref(emptyQueue())

  fun spawn(f: () -> <process, div, st<global>, exn|e> ()): <div, st<global>, exn|e> ()
    with handler
      raw ctl yield()
        q := (!q).pushBack(fn() rcontext.resume(()))
      raw ctl fork(g: () -> <process, div, exn, st<global>> ())
        q := (!q).pushBack(fn() rcontext.resume(()))
        spawn(g)
    f()

  fun driver(): <st<global>, pure> ()
    with handler
      final ctl throw-exn(err) ()
    val res = (!q).popFront()
    q := snd(res)
    fst(res)()
    driver()

  spawn(f)
  driver()

fun job(): <process, pure> ()
  yield()
  
fun jobs(n_jobs: int): <process, tick, pure> ()
  var i: int := 0;
  while {i < n_jobs}
    fork(job)
    tick()
    i := i + 1

fun run(n_jobs : int)
  var c := 0
  with handler
    fun tick() c := c + 1
  scheduler(fn () jobs(n_jobs))
  c

fun repeat(n_jobs : int)
  fun step(i: int, acc: int)
    if i == 0 then
      acc
    else 
      val r: int = run(n_jobs)
      step(i - 1, acc + r)
  step(1, 0)


pub fun main()
  val n = get-args().head("").parse-int().default(5)
  val r = repeat(n)
  println(r)