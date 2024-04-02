module main

import std/os/env

named effect emitter
  fun emit(e : int) : ()

fun range(r, l : int, u : int)
  if(l > u)
    then ()
    else
      r.emit(l)
      range(r, l + 1, u)

fun run(n : int)
  var s := 0
  with r <- named handler
    fun emit(e) 
      s := s + e 
      ()
  range(r, 0, n)
  s

pub fun main()
  val n = get-args().head("").parse-int().default(5)
  val r = run(n)
  println(r)

