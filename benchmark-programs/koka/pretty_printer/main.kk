module main

import std/os/env
import std/text/parse

effect emit
  fun emit(i: int) : ()

effect value
  fun get() : int


val constant = 0
val newline = 10
val space = 32
val star = 42
val question = 63

type node
  Constant
  While(cond : node, body : node)
  If(cond : node, then_br : node, else_br : node)

// fun make(n : int) : div node
//   if n == 0 then 
//     Constant
//   else 
//     if n % 2 == 0 then
//       While(make(n - 1), make(n - 1))
//     else
//       If(make(n - 1), make(n - 1), make(n - 1))

fun make(n : int) : div node
  if n == 0 then 
    Constant
  else 
    While(Constant, make(n - 1))

fun indent(n : int)
  var i := 0
  while {i < n}
    emit(space)
    i := i + 1

fun visit(n : node): <emit,div,value> ()
  val l = get()
  indent(l)
  with handler
    fun get() l + 1
  match n
    Constant -> 
      emit(constant)
    While(cond, body) -> 
      emit(star)
      visit(cond)
      emit(newline)
      visit(body)
    If(cond, then_br, else_br) ->
      emit(question)
      visit(cond)
      emit(newline)
      visit(then_br)
      emit(newline)
      visit(else_br)
  emit(newline)

fun run(n : int)
  var result := 0
  with handler
    fun emit(i) result := result + i
  with handler
    fun get() 0
  val ast = make(n)
  visit(ast)
  result

pub fun main()
  val n = get-args().head("").parse-int().default(5)
  val r = run(n)
  println(r)