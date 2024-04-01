
type chr = int

effect Read : unit -> chr

effect Emit : int -> unit

exception Stop


let newline = 10
let is_newline c = c = 10
let dollar = 36
let is_dollar c = c = 36

let rec parse a =
  let c = perform (Read ()) in
  if (is_dollar c)
    then parse (a + 1)
    else if (is_newline c)
      then (perform (Emit a) ; parse 0)
      else raise Stop

let sum action =
  let s = ref  0 in
  try
    (action () ; !s)
  with
  | effect (Emit e) k -> (s := !s + e ; continue k ())

let catch action =
  try
    action ()
  with
  | Stop -> ()

let feed n action =
  let i = ref 0 in
  let j = ref 0 in
  try
    action ()
  with
  | effect (Read ()) k ->
    if (!i > n)
      then raise Stop
      else if(!j = 0)
        then (i := !i + 1 ; j := !i ; continue k newline)
        else j := !j - 1 ; continue k dollar

let run n =
  sum (fun () -> catch (fun () -> feed n (fun () -> parse 0)))

let main () =
  let n = try int_of_string (Sys.argv.(1)) with _ -> 10 in
  let r = run n in
  Printf.printf "%d\n" r

let _ = main ()

