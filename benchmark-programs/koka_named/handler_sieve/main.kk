module main

import std/os/env

named effect prime
  fun prime(e : int) : bool

fun primes(r: hnd/ev<prime>, i : int, n : int, a : int): <pure> int
  if (i >= n)
    then a
    else
      if r.prime(i)
        then
          with r0 <- named handler
            fun prime(e)
              if (e % i == 0)
                then False
                else r.prime(e)
          primes(r0, i + 1, n, a + i)
        else
          primes(r, i + 1, n, a)

fun run(n : int): <pure> int
  with r <- named handler
    fun prime(e)
      True
  primes(r, 2, n, 0)

pub fun main()
  val n: int = get-args().head("").parse-int().default(5)
  val r: int = run(n)
  println(r)