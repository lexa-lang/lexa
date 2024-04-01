
effect Emit : int -> unit

let rec range l u =
  if (l > u)
    then ()
    else (
      perform (Emit l);
      range (l + 1) u)

let run n =
  let s = ref 0 in
  try
    (range 0 n;
    !s)
  with
  | effect (Emit e) k -> (s := !s + e ; continue k ())

let main () =
  let n = try int_of_string (Sys.argv.(1)) with _ -> 5 in
  let r = run n in
  Printf.printf "%d\n" r

let _ = main ()

