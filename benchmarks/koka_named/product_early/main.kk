module main

import std/os/env

named effect abort
  ctl done(i : int): a

fun product(r, xs : list<int>)
  match xs
    Nil -> 0
    Cons(y, ys) -> if y == 0 then r.done(0) else y * product(r, ys)

fun enumerate(i : int)
  if i < 0
   then Nil
   else Cons(i, enumerate(i - 1))

fun run-product(xs : list<int>)
  with r <- named handler
    ctl done(r) r
  product(r, xs)

fun run(n : int)
  val xs = enumerate(1000)
  fun loop(i : int, a : int)
    if i == 0
      then a
      else loop(i - 1, a + run-product(xs))
  loop(n, 0)

pub fun main()
  val n = get-args().head("").parse-int().default(5)
  val r = run(n)
  println(r)

