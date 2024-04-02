module main

import std/os/env
import std/text/parse

named effect choice
  ctl choice() : bool

type tree
  Leaf
  Node(left : tree, value : int, right : tree)

fun operator(x, y)
  abs (x - (503 * y) + 37) % 1009

fun make(n: int) : div tree
  if n == 0 then
    Leaf
  else
    val t = make(n - 1)
    Node(t, n, t)

fun run(n : int)

  val tree = make(n)
  var state := 0

  fun explore(r_choose: hnd/ev<choice>, t : tree)
    match t
      Leaf -> state
      Node(l, v, r) ->
        val next = if r_choose.choice() then l else r
        state := operator(state, v)
        operator(v, explore(r_choose, next))

  fun paths()
    with r <- named handler
      return(x) [x]
      ctl choice() resume(True) ++ resume(False)
    explore(r, tree)

  fun loop(i : int)
    if i == 0
      then state
      else
        state := paths().maximum
        loop(i - 1)

  loop(10)

pub fun main()
  val n = get-args().head("").parse-int().default(5)
  val r = run(n)
  println(r)
