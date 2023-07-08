fun countdown n =
  let
    val s = ref n

    fun go () =
      let
        val i = !s
      in
        if i = 0 then i
        else (
          s := i - 1;
          go ()
        )
      end
  in
    go ()
  end;

fun force opt =
  (case opt of NONE => raise Fail "force of option failed" | SOME v => v);

fun main () =
    case CommandLine.arguments () of
         []     => print ("Too few arguments!\n")
       | [arg] => print (Int.toString (countdown (force (Int.fromString arg))) ^ "\n")
       | args   => print ("Too many arguments!\n");

val _ = main ();
