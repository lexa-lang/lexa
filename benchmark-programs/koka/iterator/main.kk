module main

import std/os/env

effect fun emit(e : int) : ()

fun range(l : int, u : int)
  if(l > u)
    then ()
    else
      emit(l)
      range(l + 1, u)

fun run(n : int)
  var s := 0
  with fun emit(e)
    s := s + e
    ()
  range(0, n)
  s

pub fun main()
  val n = get-args().head("").parse-int-default(5)
  val r = run(n)
  println(r)

