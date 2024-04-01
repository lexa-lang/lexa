module main

import std/os/env

alias chr = int

effect read
  fun read(): chr

effect emit
  fun emit(e : int): ()

effect stop
  ctl stop(): a

fun newline(): chr
  10
fun is-newline(c : chr)
  c == 10
fun dollar(): chr
  36
fun is-dollar(c : chr)
  c == 36

fun parse(a : int)
  val c = read()
  if (is-dollar(c))
    then parse(a + 1)
    else if(is-newline(c))
      then
        emit(a)
        parse(0)
      else
        stop()

fun sum(action : () -> <emit|e> ()) : e int
  var s := 0
  with fun emit(e : int)
    s := s + e
  mask<local>
    action()
  s

fun catch(action : () -> <stop|e> ()) : e ()
  with ctl stop()
    ()
  action()

fun feed(n : int, action : () -> <read,stop|e> ()) : <stop|e> ()
  var i := 0
  var j := 0
  with fun read()
    if(i > n)
      then stop()
      else if(j == 0)
        then
          i := i + 1
          j := i
          newline()
        else
          j := j  - 1
          dollar()
  action()

fun run(n : int)
  sum({ catch({ feed(n, { parse(0) })})})

pub fun main()
  val n = get-args().head("").parse-int-default(10)
  val r = run(n)
  println(r)

