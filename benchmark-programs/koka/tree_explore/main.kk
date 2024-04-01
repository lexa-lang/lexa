module main

import std/os/env
import std/text/parse

effect choose
  ctl choose() : bool

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

  fun explore(t : tree)
    match t
      Leaf -> state
      Node(l, v, r) ->
        val next = if choose() then l else r
        state := operator(state, v)
        operator(v, explore(next))

  fun paths()
    with handler
      return(x) [x]
      ctl choose() resume(True) ++ resume(False)
    explore(tree)

  fun loop(i : int)
    if i == 0
      then state
      else
        state := paths().maximum
        loop(i - 1)

  loop(10)

pub fun main()
  val n = get-args().head("").parse-int-default(5)
  val r = run(n)
  println(r)
