module main

import std/os/env

alias solution = list<int>

effect search
  ctl pick(size : int) : int
  ctl fail() : a

fun safe(queen : int, diag : int, xs : solution ) : bool
  match xs
    Nil -> True
    Cons(q, qs) -> if (queen != q && queen != q + diag && queen != q - diag)
      then safe(queen, diag + 1, qs)
      else False

fun place(size : int, column : int) : <div, search> solution
  if column == 0
    then Nil
  else
    val rest = place(size, column - 1)
    val next = pick(size)
    if safe(next, 1, rest)
      then Cons(next, rest)
      else fail()

fun run(n : int)
  with handler
    return(_)        1
    ctl fail()       0
    ctl pick(size)
      fun loop(i : int, a : int)
        if i == size then
          a + resume(i)
        else
          loop(i + 1, a + resume(i))
      loop(1, 0)
  place(n, n)

pub fun main()
  val n = get-args().head("").parse-int-default(5)
  val r = run(n)
  println(r)
