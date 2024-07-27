module main

import std/os/env

effect thread
  ctl yield(): ()

fun run(n : int)
  var acc := 0
  var storage := Nothing

  fun work()
    with handler
      raw ctl yield()
        acc := acc + 1
        val peer = storage
        storage := Just(rcontext)
        if is-just(peer) then
          (unjust(peer)).resume(())
        else
          ()
    fun step(i: int)
      if i == 0 then
        ()
      else 
        yield()
        step(i - 1)
    step(n)

  work()
  work()
  acc

pub fun main()
  val n = get-args().head("").parse-int().default(5)
  val r = run(n)
  println(r)
  ()
