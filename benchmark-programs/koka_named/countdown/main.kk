module main

import std/os/env

named effect state
  fun get(): int
  fun set(i : int): ()

fun countdown(r)
  val i = r.get()
  if i == 0
    then i
    else
      r.set(i - 1)
      countdown(r)

fun run(n : int)
  var s := n
  with r <- named handler
    fun get() s
    fun set(i) s := i
  countdown(r)

pub fun main()
  val n = get-args().head("").parse-int().default(5)
  val r = run(n)
  println(r)

