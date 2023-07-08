datatype 'a List =
    Nil
  | Cons of ('a * ('a List));

fun reverseOnto l other = case l of
    Nil => other
  | Cons (head, tail) => reverseOnto tail (Cons (head, other));

fun maximum l = case l of
    Nil => ~1
  | Cons (head, tail) =>
    case tail of
        Nil => head
      | _ => let val m = maximum tail;
              in if head > m then head else m
              end;


datatype Tree =
    Leaf
  | Node of (Tree * int * Tree);

fun operator x y = abs (x - (503 * y) + 37) mod 1009

fun make n =
  if n = 0 then Leaf
  else let
    val t = make (n - 1);
    in Node (t, n, t)
  end;

fun reverse l =
  let fun loop lst acc =
      case lst of
          Nil => acc
        | Cons (head, tail) => loop tail (Cons (head, acc));
  in loop l Nil
  end;



fun run n = let
  val tree = make n;

  fun explore t y k k2 =
    case t of
      Leaf => k y k2 y
    | Node (left, middle, right) =>
      explore left (operator y middle) (fn a => k (operator middle a)) (fn a => fn y1 =>
      explore right (operator y1 middle) (fn a => k (operator middle a)) (fn a1 => fn y2 =>
      k2 (reverseOnto (reverse a) a1) y2))

  fun loop i x =
    if i = 0 then x else
      explore tree x
        (fn a => fn k2 => fn y2 => k2 (Cons (a, Nil)) y2)
        (fn a => fn _ => loop (i - 1) (maximum a));
    in loop 10 0
  end;

fun force opt =
  (case opt of NONE => raise Fail "force of option failed" | SOME v => v);

fun main () =
    case CommandLine.arguments () of
        []     => print ("Too few arguments!\n")
      | [arg] => print (Int.toString (run (force (Int.fromString arg))) ^ "\n")
      | args   => print ("Too many arguments!\n");

val _ = main ();
