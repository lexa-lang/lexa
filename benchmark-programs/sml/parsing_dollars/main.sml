
fun run n =
  let fun parse a x y z =
    if y > n
      then z
      else if x = 0
        then parse 0 (y + 1) (y + 1) (z + a)
        else parse (a + 1) (x - 1) y z
    in
      parse 0 0 0 0
    end

fun force opt =
  (case opt of NONE => raise Fail "force of option failed" | SOME v => v);

fun main () =
    case CommandLine.arguments () of
        []     => print ("Too few arguments!\n")
      | [arg] => print (Int.toString (run (force (Int.fromString arg))) ^ "\n")
      | args   => print ("Too many arguments!\n");

val _ = main ();
