import std/os/env

named effect yield
  ctl yield(x : int) : ()

type tree
  Leaf
  Node(left : tree, value : int, right : tree)

type generator<e>
  Empty
  Thunk(value : int, next: () -> <div|e> generator<e>)

fun make(n : int) : div tree
  if n == 0 then
    Leaf
  else
    val t = make(n - 1)
    Node(t, n, t)

fun iterate(t : tree, r: hnd/ev<yield>): pure ()
  match t
    Leaf -> ()
    Node(left, v, right) ->
      iterate(left, r)
      r.yield(v)
      iterate(right, r)

fun generate(f: (hnd/ev<yield>) -> <div|e> ()): <div|e> generator<e>
  with r <- named handler
    return(_) Empty
    ctl yield(x)
      Thunk(x, fn() { resume(())})
  f(r)

fun sum(a : int, g : generator<e>): <div|e> int
  match g
    Empty -> a
    Thunk(v, f) -> sum(v + a, f())

fun run(n : int): pure int
  val f: (hnd/ev<yield>) -> pure () = fn(r: hnd/ev<yield>) { iterate(make(n), r)}
  sum(0, generate(f))

pub fun main()
  val n = get-args().head("").parse-int().default(5)
  val r = run(n)
  println(r)