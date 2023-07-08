datatype ('a, 'b, 'c) Triple =
  Triple of ('a * 'b * 'c);

fun choice n k =
  if n < 1 then 0
  else ((k n) + (choice (n - 1) k)) mod 1000000007;

fun run n =
  choice n (fn i =>
    choice (i - 1) (fn j =>
      choice (j - 1) (fn k =>
        if (i + j + k) = n
        then ((53 * i) + (2809 * j) + (148877 *  k)) mod 1000000007
        else 0)));

fun force opt =
  (case opt of NONE => raise Fail "force of option failed" | SOME v => v);

fun main () =
    case CommandLine.arguments () of
        []     => print ("Too few arguments!\n")
      | [arg] => print (Int.toString (run (force (Int.fromString arg))) ^ "\n")
      | args   => print ("Too many arguments!\n");

val _ = main ();
