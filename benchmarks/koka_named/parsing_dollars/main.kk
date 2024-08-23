module main

import std/os/env

alias chr = int

named effect read
  fun read(): chr

named effect emit
  fun emit(e : int): ()

named effect stop
  ctl stop(): a

fun newline(): chr
  10
fun is-newline(c : chr)
  c == 10
fun dollar(): chr
  36
fun is-dollar(c : chr)
  c == 36

fun parse(r_emit, r_stop, r_read, a : int)
  val c = r_read.read()
  if (is-dollar(c))
    then parse(r_emit, r_stop, r_read, a + 1)
    else if(is-newline(c))
      then
        r_emit.emit(a)
        parse(r_emit, r_stop, r_read, 0)
      else
        r_stop.stop()

fun sum(action : (hnd/ev<emit>) -> <|e> ()) : e int
  var s := 0
  with r <- named handler
    fun emit(e : int)
      s := s + e
  mask<local>
    action(r)
  s

fun catch(action : (hnd/ev<stop>) -> <|e> ()) : e ()
  with r <- named handler
    ctl stop()
      ()
  action(r)

fun feed(r_stop, n : int, action: (hnd/ev<read>) -> <pure> ()) : pure ()
  var i := 0
  var j := 0
  with r <- named handler
    fun read()
      if(i > n)
        then r_stop.stop()
        else if(j == 0)
          then
            i := i + 1
            j := i
            newline()
          else
            j := j  - 1
            dollar()
  action(r)

fun run(n : int)
  sum(fn(r_emit){ catch(fn(r_stop){ feed(r_stop, n, fn(r_read){ parse(r_emit,r_stop,r_read,0) })})})

pub fun main()
  val n = get-args().head("").parse-int().default(10)
  val r = run(n)
  println(r)

