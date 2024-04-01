
effect Get : unit -> int
effect Set : int -> unit

let rec countdown () =
  let i = perform (Get ()) in
  if (i = 0)
    then i
    else (
      perform (Set (i - 1));
      countdown ())

let run n =
  let s = ref (n : int) in
  try
    countdown ()
  with
  | effect (Get ()) k -> continue k (!s)
  | effect (Set i) k -> s := i; continue k ()

let main () =
  let n = try int_of_string (Sys.argv.(1)) with _ -> 5 in
  let r = run n in
  Printf.printf "%d\n" r

let _ = main ()

