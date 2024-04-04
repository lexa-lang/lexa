module main

import std/os/env

named effect replace
  fun replace(x: int): ()
named effect behead
  fun behead(): ()
named effect yield
  fun yield(x: int, r_replace: hnd/ev<replace>, r_behead: hnd/ev<behead>): ()


fun loop(it: list<int>, r_yield: hnd/ev<yield>, r_behead: hnd/ev<behead>): pure list<int>
  var hd := it.default/head(0)
  val tl = it.tail()
  var beheaded := False
  with r_replace <- named handler
    fun replace(x: int)
      hd := x
  r_yield.yield(hd, r_replace, r_behead)
  val newtl = 
    if is-empty(tl) then
      []
    else
      with r_behead1 <- named handler
        fun behead() beheaded := True
      loop(tl, r_yield, r_behead1)
  if beheaded then
    Cons(hd, drop(newtl, 1))
  else
    Cons(hd, newtl)
  

fun run(n : int)
  val l = list(0-n, n)
  var beheaded := False
  with r_yield <- named handler
    fun yield(x: int, r_replace: hnd/ev<replace>, r_behead: hnd/ev<behead>)
      if x < 0 then
        r_behead.behead()
      else
        r_replace.replace(x*2)
  with r_behead <- named handler
    fun behead() beheaded := True
  val res: list<int> = loop(l, r_yield, r_behead)
  if beheaded then
    drop(res, 1)
  else
    res

pub fun main()
  val n = get-args().head("").parse-int().default(5)
  val r = run(n)
  println(r)
