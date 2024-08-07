module main

import std/os/env
import std/text/parse

named effect yield
  ctl yield() : ()

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
  val state = ref(0)
  var storage := Nothing

  fun yield_f(action)
    with r <- named handler
      raw ctl yield()
          val peer = storage
          storage := Just(rcontext)
          if is-just(peer) then
            (unjust(peer)).resume(True)
          else
            0
    action(r)

  fun explore(r_yield: hnd/ev<yield>, t : tree, rev : bool)
    r_yield.yield()
    match t
      Leaf -> state
      Node(l, v, r) ->
        state := operator(!state, v)
        if !rev then
          v + explore(r_yield, l, rev) + explore(r_yield, r, rev)
        else
          v + explore(r_yield, r, rev) + explore(r_yield, l, rev)
        
  fun search()
    yield_f(fn(r) explore(r, tree, True))
    yield_f(fn(r) explore(r, tree, False))

  fun loop(i)
    if i == 0
      then !state
      else
        state := search()
        loop(i - 1)

  loop(1000)

pub fun main()
  val n = get-args().head("").parse-int().default(5)
  val r = run(n)
  println(r)
