module main

import std/os/env

effect fun prime(e : int) : bool

fun primes(i : int, n : int, a : int): <div,prime> int
  if (i >= n)
    then a
    else
      if prime(i)
        then
          with fun prime(e)
            if (e % i == 0)
              then False
              else prime(e)
          primes(i + 1, n, a + i)
        else
          primes(i + 1, n, a)

pub fun run(n : int)
  with fun prime(e)
    True
  primes(2, n, 0)

pub fun main()
  val n = get-args().head("").parse-int().default(5)
  val r = run(n)
  println(r)