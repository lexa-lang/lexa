datatype 'a List =
    Nil
  | Cons of ('a * ('a List));

fun product xs k1 =
  case xs of
      Nil => k1 0
    | Cons (head, tail) =>
        if head = 0
        then 0
        else product tail (fn a => k1 (head * a));

fun enumerate i =
  if i < 0 then Nil else Cons (i, enumerate (i - 1));

fun run n =
  let
    val xs = enumerate 1000;
    fun loop i a =
      if (i = 0) then a
      else
        let val tmp = product xs (fn a => a);
        in loop (i - 1) (a + tmp)
      end;
  in loop n 0
  end;

fun force opt =
  (case opt of NONE => raise Fail "force of option failed" | SOME v => v);

fun main () =
    case CommandLine.arguments () of
         []     => print ("Too few arguments!\n")
       | [arg] =>
          let val n = force (Int.fromString arg);
          in
            print (Int.toString (run n))
          end
       | args   => print ("Too many arguments!\n");

val _ = main ();