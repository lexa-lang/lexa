
effect Operator : int -> unit

let rec loop i s =
  if i = 0
    then s
    else
      let _ = perform (Operator i) in
      loop (i - 1) s

let run n s =
  match loop n s with
  | x -> x
  | effect (Operator x) k ->
      let y = continue k () in
      abs (x - (503 * y) + 37) mod 1009

let rec repeat n =
  let rec step l s =
    if l = 0
      then s
      else step (l - 1) (run n s) in
  step 1000 0

let main () =
  let n = try int_of_string (Sys.argv.(1)) with _ -> 5 in
  let r = repeat n in
  Printf.printf "%d\n" r

let _ = main ()

