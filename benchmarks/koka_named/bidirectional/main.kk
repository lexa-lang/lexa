module main

import std/os/env

named effect hdl1
  fun hdl1(): ()
named effect hdl2
  fun hdl2(x: hnd/ev<hdl1>): ()

fun run(n : int)
  var s := n
  with rb <- named handler
    fun hdl2(x: hnd/ev<hdl1>)
      x.hdl1()
      println("in hdl2")
  with ra <- named handler
    fun hdl1()
      println("in hdl1")
  rb.hdl2(ra)

pub fun main()
  val n = get-args().head("").parse-int().default(5)
  val r = run(n)
  println(r)

