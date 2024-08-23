module main

import std/os/env

effect yield
  ctl yield(x : int) : ()

type tree
  Leaf
  Node(left : tree, value : int, right : tree)

type generator
  Empty
  Thunk(value : int, next: () -> div generator)

fun make(n : int) : div tree
  if n == 0 then
    Leaf
  else
    val t = make(n - 1)
    Node(t, n, t)

fun iterate(t : tree) : yield ()
  match t
    Leaf -> ()
    Node(l, v, r) ->
      iterate(l)
      yield(v)
      iterate(r)

fun generate(f : () -> <yield,div> ()): div generator
  with handler
    return(_) Empty
    ctl yield(x)
      Thunk(x, fn() { resume(())})
  f()

fun sum(a : int, g : generator) : div int
  match g
    Empty -> a
    Thunk(v, f) -> sum(v + a, f())

fun run(n : int): div int
  sum(0, generate({ iterate(make(n))}))

pub fun main()
  val n = get-args().head("").parse-int().default(5)
  val r = run(n)
  println(r)

