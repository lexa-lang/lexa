module main

import std/os/env

named effect operator
  ctl operator(x : int) : ()

fun loop(r, i : int, s : int) : pure int
  if (i == 0)
    then s
    else
      r.operator(i)
      loop(r, i - 1, s) + 1

fun run(n : int, s : int) : pure int
  with r <- named handler
    ctl operator(x : int)
      val y = resume(())
      abs (x - (503 * y) + 37) % 1009
  loop(r, n, s)

fun repeat(n : int) : pure int
  fun step(l, s)
    if (l == 0)
      then s
      else step(l - 1, run(n, s))
  // loop count reduced from 1000
  step(10, 0)

pub fun main()
  val n = get-args().head("").parse-int().default(5)
  val r = repeat(n)
  println(r)
