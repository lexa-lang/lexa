fun loop i s =
  if i = 0 then s else
    let
      val y = loop (i - 1) s
    in
      abs (i - (503 * y) + 37) mod 1009
  end;

fun run n =
  let fun step l s =
    if l = 0 then s
    else step (l - 1) (loop n s);
  in step 1000 0 end;

fun force opt =
  (case opt of NONE => raise Fail "force of option failed" | SOME v => v);

fun main () =
    case CommandLine.arguments () of
        []     => print ("Too few arguments!\n")
      | [arg] => print (Int.toString (run (force (Int.fromString arg))) ^ "\n")
      | args   => print ("Too many arguments!\n");

val _ = main ();
