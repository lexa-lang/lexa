module main

import std/os/env

effect state
  fun get(): int
  fun set(i : int): ()

fun countdown()
  val i = get()
  if i == 0
    then i
    else
      set(i - 1)
      countdown()

fun run(n : int)
  var s := n
  with handler
    fun get() s
    fun set(i) s := i
  countdown()

pub fun main()
  val n = get-args().head("").parse-int-default(5)
  val r = run(n)
  println(r)

