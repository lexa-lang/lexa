module main

import std/os/env

effect thread
  ctl yield(): ()

type tree
  Leaf
  Node(left : tree, value : int, right : tree)

fun make(n: int) : div tree
  if n == 0 then
    Leaf
  else
    val t = make(n - 1)
    Node(t, n, t)

fun run(n : int)
  var acc := 0
  var storage := Nothing

  fun yield_f(action)
    with handler
      raw ctl yield()
          val peer = storage
          storage := Just(rcontext)
          if is-just(peer) then
            (unjust(peer)).resume(())
          else
            0
    action()
  fun explore(t : tree, rev : bool)
    yield()
    match t
      Leaf -> 0
      Node(l, v, r) ->
        if !rev then
          v + explore(l, rev) + explore(r, rev)
        else
          v + explore(r, rev) + explore(l, rev)
  val tree = make(n)
  
  yield_f(fn() explore(tree, True))
  yield_f(fn() explore(tree, False))

pub fun main()
  val n = get-args().head("").parse-int().default(5)
  val r = run(n)
  println(r)
  ()
