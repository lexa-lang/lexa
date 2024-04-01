module main

import std/os/env

effect ctl operator(x : int) : ()

fun loop(i : int, s : int) : <div, operator> int
  if (i == 0)
    then s
    else
      operator(i)
      loop(i - 1, s)

fun run(n : int, s : int) : div int
  with ctl operator(x : int)
    val y = resume(())
    abs (x - (503 * y) + 37) % 1009
  loop(n, s)

fun repeat(n : int) : div int
  fun step(l, s)
    if (l == 0)
      then s
      else step(l - 1, run(n, s))
  step(1000, 0)

pub fun main()
  val n = get-args().head("").parse-int-default(5)
  val r = repeat(n)
  println(r)
