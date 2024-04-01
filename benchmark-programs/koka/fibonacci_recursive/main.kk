module main

import std/os/env

fun fibonacci(n : int) : div int
  if (n == 0)
    then 0
    else if (n == 1)
      then 1
      else fibonacci(n - 1) + fibonacci(n - 2)

pub fun main()
  val n = get-args().head("").parse-int-default(5)
  val r = fibonacci(n)
  println(r)

