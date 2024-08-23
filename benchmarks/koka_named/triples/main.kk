module main

import std/os/env

named effect flip
  ctl flip() : bool
named effect fail
  ctl fail<a>() : a

fun choice(r_flip, r_fail, n : int)
  if (n < 1)
    then r_fail.fail()
  elif (r_flip.flip())
    then n
  else choice(r_flip, r_fail, n - 1)

fun triple(r_flip, r_fail, n : int, s: int)
  val i = choice(r_flip, r_fail, n)
  val j = choice(r_flip, r_fail, i - 1)
  val k = choice(r_flip, r_fail, j - 1)
  if i + j + k == s
    then (i, j, k)
  else r_fail.fail()

fun hash((a,b,c)) : int
  (53 * a + 2809 * b + 148877 * c) % 1000000007

fun run(n : int, s : int) : pure int
  with r_flip <- named handler
    ctl flip()
      ((resume(True) : int) + resume(False)) % 1000000007
  with r_fail <- named handler
    ctl fail()
      0
  hash(triple(r_flip, r_fail, n, s))

pub fun main()
  val n = get-args().head("").parse-int().default(10)
  val r = run(n, n)
  println(r)
