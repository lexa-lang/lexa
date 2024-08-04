module main

import std/os/env

effect thread
  ctl yield(): ()

type tree
  Leaf
  Node(left : tree, value : int, right : tree)

fun operator(x, y)
  abs (x - (503 * y) + 37) % 1009

fun make(n: int) : div tree
  if n == 0 then
    Leaf
  else
    if n % 30 == 0 then
      val t = make(n - 1)
      Node(t, n, t)
    else
      val t = make(n - 1)
      Node(t, n, Leaf)
    

fun run(n : int)
  val tree = make(n)
  val state = ref(0)
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
      Leaf -> !state
      Node(l, v, r) ->
        state := operator(!state, v)
        if !rev then
          v + explore(l, rev) + explore(r, rev)
        else
          v + explore(r, rev) + explore(l, rev)
  
  fun search()
    yield_f(fn() explore(tree, True))
    yield_f(fn() explore(tree, False))

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
  ()
