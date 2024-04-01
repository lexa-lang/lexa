datatype 'a List =
  Nil
  | Cons of ('a * ('a List));

fun safe queen diag xs =
  case xs of
    Nil => true
  | Cons (q, qs) =>
      if queen <> q andalso queen <> (q + diag) andalso queen <> (q - diag)
      then safe queen (diag + 1) qs
      else false;

fun place size column k =
  if column = 0 then
    k Nil
  else
    place size (column - 1) (fn rest =>
      let
        fun loop i a =
          let
            val n = if safe i 1 rest then k (Cons (i, rest)) else 0
          in
            if i = size then
              a + n
            else
              loop (i + 1) (a + n)
          end
      in loop 1 0
      end
    );


fun run n =
  place n n (fn a => 1)

fun force opt =
    (case opt of NONE => raise Fail "force of option failed" | SOME v => v);

fun main () =
    case CommandLine.arguments () of
        []     => print ("Too few arguments!\n")
      | [arg] => print (Int.toString (run (force (Int.fromString arg))) ^ "\n")
      | args   => print ("Too many arguments!\n");

val _ = main ();
