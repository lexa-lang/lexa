datatype 'a List =
    Nil
  | Cons of ('a * ('a List));

exception Zero

fun product xs =
  case xs of
      Nil => 0
    | Cons (y, ys) => if y = 0 then raise Zero else y * product ys

fun enumerate i =
  if i < 0 then Nil else Cons (i, enumerate (i - 1));

fun run_product xs =
  product xs handle Zero => 0

fun run n =
  let
    val xs = enumerate 1000;
    fun loop i a =
      if (i = 0) then a
      else loop (i - 1) (a + run_product xs)
  in loop n 0
  end;

fun force opt =
  (case opt of NONE => raise Fail "force of option failed" | SOME v => v);

fun main () =
    case CommandLine.arguments () of
        []     => print ("Too few arguments!\n")
      | [arg] => print (Int.toString (run (force (Int.fromString arg))) ^ "\n")
      | args   => print ("Too many arguments!\n");

val _ = main ();
